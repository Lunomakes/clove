#!/usr/bin/env python3
"""release-zh.sh 的只读元数据与产物验证；仅使用标准库。"""
import base64
import json
import os
from pathlib import Path
import pwd
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

REPO = 'https://github.com/Lunomakes/clove'
SPARKLE = '{http://www.andymatuschak.org/xml-namespaces/sparkle}'


def next_version(project, tags):
    targets = [v for v in project['objects'].values()
               if v.get('isa') == 'PBXNativeTarget' and v.get('name') == 'Clove']
    if len(targets) != 1:
        raise ValueError('找不到唯一的 Clove app target')
    objects = project['objects']
    configurations = objects[targets[0]['buildConfigurationList']]['buildConfigurations']
    values = {(objects[c]['buildSettings']['MARKETING_VERSION'],
               str(objects[c]['buildSettings']['CURRENT_PROJECT_VERSION'])) for c in configurations}
    if len(values) != 1:
        raise ValueError('Clove app target 的 Debug/Release 版本不一致')
    version, build = values.pop()
    if not re.fullmatch(r'\d+(?:\.\d+)+', version) or not build.isdigit():
        raise ValueError('项目必须保留上游数值版本和 build')
    pattern = re.compile(r'v' + re.escape(version) + r'-zh(?:\.(\d+))?')
    revisions = [int(m[1] or 0) for tag in tags if (m := pattern.fullmatch(tag))]
    revision = max(revisions, default=0) + 1
    return f'{version}-zh.{revision}', str(int(build) * 100 + revision)


def verify_private_paths(bundle):
    needles = {os.fsencode(os.environ['HOME']), os.fsencode(pwd.getpwuid(os.getuid()).pw_name)}
    overlap = max(map(len, needles)) - 1
    for path in bundle.rglob('*'):
        metadata = os.fsencode(path.relative_to(bundle))
        if path.is_symlink():
            metadata += os.fsencode(os.readlink(path))
        if any(needle in metadata for needle in needles):
            raise ValueError(f'产物路径或链接含本机 home 路径或用户名：{path.relative_to(bundle)}')
        if path.is_symlink() or not path.is_file():
            continue
        # Scan bytes, including executables and compiled resources, without printing the private value.
        with path.open('rb') as stream:
            tail = b''
            while chunk := stream.read(1024 * 1024):
                data = tail + chunk
                if any(needle in data for needle in needles):
                    raise ValueError(f'产物含本机 home 路径或用户名：{path.relative_to(bundle)}')
                tail = data[-overlap:] if overlap else b''


def verify_appcast(path, version, build):
    channel = ET.parse(path).getroot().find('channel')
    items = channel.findall('item') if channel is not None else []
    if len(items) != 1:
        raise ValueError('appcast 必须只含本次发布')
    enclosure = items[0].find('enclosure')
    if enclosure is None:
        raise ValueError('appcast 缺少 enclosure')
    attrs = enclosure.attrib
    if items[0].findtext(SPARKLE + 'version') != build:
        raise ValueError('appcast sparkle:version 不等于注入的 build')
    if items[0].findtext(SPARKLE + 'shortVersionString') != version:
        raise ValueError('appcast shortVersionString 不等于注入的版本')
    if len(base64.b64decode(attrs.get(SPARKLE + 'edSignature', ''), validate=True)) != 64:
        raise ValueError('appcast 缺少有效格式的 sparkle:edSignature')
    expected = f'{REPO}/releases/download/v{version}/Clove-{version}.dmg'
    if attrs.get('url') != expected:
        raise ValueError('appcast 下载地址不属于本次 fork release')


def main():
    command, *args = sys.argv[1:]
    if command == 'version':
        data = subprocess.check_output(['plutil', '-convert', 'json', '-o', '-', args[0]])
        tags = subprocess.check_output(['git', 'tag', '--list'], text=True).splitlines()
        print(*next_version(json.loads(data), tags))
    elif command == 'privacy':
        verify_private_paths(Path(args[0]))
        print('隐私扫描通过：bundle 不含本机 home 路径或用户名。')
    elif command == 'appcast':
        verify_appcast(Path(args[0]), args[1], args[2])
        print('appcast 检查通过：EdDSA 签名、版本、build、fork 下载地址。')
    else:
        raise ValueError(f'未知检查：{command}')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError, ET.ParseError, subprocess.CalledProcessError) as error:
        sys.exit(f'发布检查失败：{error}')
