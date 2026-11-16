#!/usr/bin/env python3
"""以 python3 -I 运行；Release 编译提取结果是代码用键的依据。"""
import collections
import json
from pathlib import Path
import re
import sys

LOCALES = ('en', 'zh-Hans', 'zh-Hant')
FORMAT = re.compile(r'%(?:(\d+)\$)?[-+ #0]*(?:\d+)?(?:\.\d+)?(hh[diouxX]|h[diouxX]|ll[diouxX]|l[diouxXf]|z[diouxX]|[diouxXfFeEgGaAcCsSp@%])')


def placeholders(text):
    result = collections.Counter()
    ordinal = 0
    for match in FORMAT.finditer(text):
        if match[2] == '%':
            continue
        ordinal += 1
        result[(int(match[1] or ordinal), match[2])] += 1
    return result


def units(node, path=()):
    if not isinstance(node, dict):
        return
    if 'stringUnit' in node:
        yield path, node['stringUnit']
    for key, value in node.items():
        if key != 'stringUnit':
            yield from units(value, path + (key,))


def validate_catalog(catalog, name):
    errors = []
    if catalog.get('sourceLanguage') != 'en':
        errors.append(f'{name}: sourceLanguage 必须为 en')
    for key, entry in catalog['strings'].items():
        label = f'{name}: {key!r}'
        if entry.get('extractionState') == 'stale':
            errors.append(f'{label}: stale 键')
        expected = placeholders(key)
        for locale in LOCALES:
            local = entry.get('localizations', {}).get(locale)
            leaves = list(units(local))
            if not leaves:
                errors.append(f'{label}: 缺少 {locale} 翻译')
            for path, unit in leaves:
                where = f'{label} [{locale}/{"/".join(path)}]'
                if unit.get('state') != 'translated':
                    errors.append(f'{where}: state 不是 translated')
                actual = placeholders(unit.get('value', ''))
                # Existing English singular spells out "One item" instead of %lld.
                spelled_one = (locale == 'en' and path == ('variations', 'plural', 'one')
                               and key == "%lld items couldn't be removed. They may be in use."
                               and unit.get('value') == "One item couldn't be removed. It may be in use.")
                if actual != expected and not spelled_one:
                    errors.append(f'{where}: 占位符不匹配 {dict(expected)} -> {dict(actual)}')
                if locale == 'zh-Hant' and any(q in unit.get('value', '') for q in '“”'):
                    errors.append(f'{where}: 繁体引号应使用「」')
    return errors


def extracted_keys(directory):
    keys = collections.defaultdict(dict)
    files = sorted(directory.rglob('*.stringsdata'))
    for path in files:
        data = json.loads(path.read_text(encoding='utf-8'))
        for table, entries in data.get('tables', {}).items():
            for entry in entries:
                keys[table][entry['key']] = data.get('source', str(path))
    return files, keys


def main():
    root = Path(__file__).resolve().parent.parent
    errors = []
    directory = root / 'build/Build/Intermediates.noindex/Clove.build/Release/Clove.build'
    try:
        files, extracted = extracted_keys(directory)
        if not files or not extracted.get('Localizable'):
            errors.append('缺少 Release .stringsdata；请先运行 Release build。')
        for table in ('Localizable', 'InfoPlist'):
            path = root / 'Clove' / f'{table}.xcstrings'
            catalog = json.loads(path.read_text(encoding='utf-8'))
            errors.extend(validate_catalog(catalog, path.name))
            for key, source in extracted.get(table, {}).items():
                if key not in catalog['strings']:
                    errors.append(f'{path.name}: 编译器提取的键缺失 {key!r}，来源 {source}')
            print(f'{path.name}: {len(catalog["strings"])} 个键；编译器提取 {len(extracted.get(table, {}))} 个键')
    except (OSError, ValueError, KeyError, TypeError) as error:
        errors.append(f'无法验证本地化：{error}')
    if errors:
        print('\n'.join(f'- {error}' for error in errors), file=sys.stderr)
        return 1
    print(f'本地化检查通过：三种语言、翻译状态、占位符、无 stale 键、{len(files)} 个提取文件。')
    return 0


if __name__ == '__main__':
    sys.exit(main())
