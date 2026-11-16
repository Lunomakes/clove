"""发布安全边界与本地化验证的回归检查；python3 -I -B -m unittest discover -s tools/tests。"""
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

TOOLS = Path(__file__).resolve().parents[1]


def load(name):
    spec = importlib.util.spec_from_file_location(name, TOOLS / f'{name}.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


localization = load('check-localization')
release = load('fork-release')


class LocalizationChecks(unittest.TestCase):
    def catalog(self):
        return {'sourceLanguage': 'en', 'strings': {'Used %@': {'localizations': {
            locale: {'stringUnit': {'state': 'translated', 'value': 'Used %@'}}
            for locale in localization.LOCALES}}}}

    def test_rejects_missing_locale_stale_and_placeholder(self):
        catalog = self.catalog()
        self.assertEqual(localization.validate_catalog(catalog, 'fixture'), [])
        entry = catalog['strings']['Used %@']
        entry['extractionState'] = 'stale'
        del entry['localizations']['en']
        entry['localizations']['zh-Hans']['stringUnit']['value'] = '使用过 %lld'
        errors = localization.validate_catalog(catalog, 'fixture')
        self.assertEqual(len(errors), 3)
        self.assertTrue(any('stale' in e for e in errors))
        self.assertTrue(any('en' in e for e in errors))
        self.assertTrue(any('占位符' in e for e in errors))

    def test_plural_and_reordered_placeholders(self):
        self.assertEqual(localization.placeholders('%lld items · %@'), localization.placeholders('%2$@：%1$lld 项'))
        catalog = self.catalog()
        catalog['strings']['Used %@']['localizations']['en'] = {'variations': {'plural': {
            'one': {'stringUnit': {'state': 'translated', 'value': 'Used %@'}},
            'other': {'stringUnit': {'state': 'needs_review', 'value': 'Used %@'}}}}}
        self.assertEqual(len(localization.validate_catalog(catalog, 'fixture')), 1)

    def test_compiler_key_extraction(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'Example.stringsdata'
            path.write_text(json.dumps({'source': 'Example.swift', 'tables': {'Localizable': [{'key': 'Missing key'}]}}))
            files, tables = localization.extracted_keys(Path(directory))
            self.assertEqual(files, [path])
            self.assertEqual(tables['Localizable'], {'Missing key': 'Example.swift'})


class ReleaseChecks(unittest.TestCase):
    def project(self):
        return {'objects': {'app': {'isa': 'PBXNativeTarget', 'name': 'Clove', 'buildConfigurationList': 'list'},
                            'list': {'buildConfigurations': ['debug', 'release']},
                            **{c: {'buildSettings': {'MARKETING_VERSION': '3.2', 'CURRENT_PROJECT_VERSION': '13'}}
                               for c in ('debug', 'release')},
                            'test': {'buildSettings': {'MARKETING_VERSION': '99', 'CURRENT_PROJECT_VERSION': '999'}}}}

    def test_app_target_version_legacy_and_numeric_tags(self):
        project = self.project()
        self.assertEqual(release.next_version(project, ['v3.2-zh']), ('3.2-zh.1', '1301'))
        self.assertEqual(release.next_version(project, ['v3.2-zh.2', 'v3.2-zh.10', 'v3.3-zh.99']), ('3.2-zh.11', '1311'))
        self.assertEqual(release.next_version(project, []), ('3.2-zh.1', '1301'))
        project['objects']['debug']['buildSettings']['MARKETING_VERSION'] = '3.3'
        with self.assertRaises(ValueError):
            release.next_version(project, [])

    def test_appcast_rejects_wrong_build_unsigned_or_upstream(self):
        # Synthetic enclosure: the parser validates metadata, not EdDSA cryptography.
        import base64
        signature = base64.b64encode(bytes(64)).decode()
        good = f'''<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"><channel><item><sparkle:version>1301</sparkle:version><sparkle:shortVersionString>3.2-zh.1</sparkle:shortVersionString><enclosure sparkle:edSignature="{signature}" url="https://github.com/Lunomakes/clove/releases/download/v3.2-zh.1/Clove-3.2-zh.1.dmg"/></item></channel></rss>'''
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'appcast.xml'
            path.write_text(good)
            release.verify_appcast(path, '3.2-zh.1', '1301')
            for old, new in [('1301', '13'), (signature, ''), ('Lunomakes', 'keshav-exe')]:
                path.write_text(good.replace(old, new))
                with self.assertRaises(ValueError):
                    release.verify_appcast(path, '3.2-zh.1', '1301')

    def test_private_bytes_across_chunk_boundary_and_external_symlinks(self):
        with tempfile.TemporaryDirectory() as directory:
            bundle = Path(directory)
            file = bundle / 'Clove'
            file.write_bytes(b'normal app')
            with patch.dict(os.environ, {'HOME': '/private/home/fixture'}):
                release.verify_private_paths(bundle)
                file.write_bytes(b'x' * (1024 * 1024 - 8) + b'/private/home/fixture/path')
                with self.assertRaises(ValueError):
                    release.verify_private_paths(bundle)
                file.unlink()
                (bundle / 'Applications').symlink_to('/Applications')
                release.verify_private_paths(bundle)
                (bundle / 'PrivateLink').symlink_to('/private/home/fixture/secret')
                with self.assertRaises(ValueError):
                    release.verify_private_paths(bundle)


if __name__ == '__main__':
    unittest.main()
