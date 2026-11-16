#!/usr/bin/env bash
set -euo pipefail

# Fork releases use ad-hoc signing plus an EdDSA-signed archive. Sparkle's
# SUUpdateValidator.validateUpdateForHost accepts valid EdDSA even when the old
# designated requirement (ad-hoc cdhash) differs; it still verifies the new app's
# code signature independently. See Sparkle/SUUpdateValidator.m:306-388 and
# Autoupdate/SUCodeSigningVerifier.m:139-170 in build/SourcePackages/checkouts/Sparkle.
# Apple Development is unnecessary here: it is not Developer ID/notarization,
# embeds personal certificate metadata, and needs all nested code re-signed to
# avoid Team ID/library-validation mismatches. Re-sign the whole bundle ad-hoc
# after stripping; preserve helper entitlements. Never export the EdDSA key.
#
# Usage: tools/release-zh.sh [notes.md] [--dry-run]
# Publishing requires clean main. A dry run accepts a clean review branch too.
# Setup once: build/.../Sparkle/bin/generate_keys --account clove-zh

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"
fail() { echo "错误：$*" >&2; exit 1; }
NOTES=""
DRY_RUN=0
for argument in "$@"; do
  case "${argument}" in
    --dry-run) DRY_RUN=1 ;;
    --*) fail "用法：tools/release-zh.sh [notes.md] [--dry-run]" ;;
    *) [[ -z "${NOTES}" ]] || fail "只能指定一份发布说明"; NOTES="${argument}" ;;
  esac
done
[[ -z "${NOTES}" || -f "${NOTES}" ]] || fail "找不到发布说明：${NOTES}"
[[ -z "$(git status --porcelain)" ]] || fail "请先提交工作树中的改动"
BRANCH="$(git symbolic-ref --quiet --short HEAD)" || fail "请在分支上运行"
[[ "${BRANCH}" == main || "${DRY_RUN}" == 1 ]] || fail "正式发布必须在 main 上运行"
# Check fetch AND every push URL, before any build or publishing action.
for remote_url in "$(git remote get-url origin)" $(git remote get-url --push --all origin); do
  case "${remote_url}" in
    https://github.com/Lunomakes/clove|https://github.com/Lunomakes/clove.git|git@github.com:Lunomakes/clove.git) ;;
    *) fail "origin 必须是 Lunomakes/clove" ;;
  esac
done
command -v gh >/dev/null || fail "需要安装 GitHub CLI"
gh auth status >/dev/null 2>&1 || fail "请先完成 gh auth login"
# Read remote tags without mutating refs, so a stale local tag list cannot reuse a version.
REMOTE_TAGS="$(git ls-remote --tags origin)" || fail "无法读取 origin tags"
while read -r _ ref; do
  [[ -n "${ref}" && "${ref}" != *'^{}' ]] || continue
  git show-ref --verify --quiet "${ref}" || fail "本地缺少 ${ref}；请先 git fetch origin --tags"
done <<< "${REMOTE_TAGS}"
read -r VERSION BUILD < <(python3 -I tools/fork-release.py version Clove.xcodeproj/project.pbxproj)
[[ -n "${VERSION:-}" && -n "${BUILD:-}" ]] || fail "无法计算版本"
TAG="v${VERSION}"
SOURCE_COMMIT="$(git rev-parse HEAD)"
git rev-parse --verify --quiet "refs/tags/${TAG}" >/dev/null && fail "${TAG} 已存在"
echo "Clove ${VERSION} / build ${BUILD}（分支 ${BRANCH}，dry-run=${DRY_RUN}）"

# No inherited CLOVE_LICENSED: fork builds are license-free.
xcodebuild -scheme Clove -configuration Release -destination 'platform=macOS' \
  -derivedDataPath build CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= \
  MARKETING_VERSION="${VERSION}" CURRENT_PROJECT_VERSION="${BUILD}" \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS= build
python3 -I tools/check-localization.py
APP="${ROOT}/build/Build/Products/Release/Clove.app"
SPARKLE_BIN="${ROOT}/build/SourcePackages/artifacts/sparkle/Sparkle/bin"
[[ -d "${APP}" && -x "${SPARKLE_BIN}/generate_appcast" ]] || fail "构建产物或 Sparkle 工具缺失"
PUBLIC_KEY="$("${SPARKLE_BIN}/generate_keys" --account clove-zh -p)"
[[ "${PUBLIC_KEY}" == "$(/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' "${APP}/Contents/Info.plist")" ]] \
  || fail "Keychain 公钥与 app 公钥不一致"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "${APP}/Contents/Info.plist")" == "${BUILD}" ]] || fail "app build 不符"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "${APP}/Contents/Info.plist")" == "${VERSION}" ]] || fail "app 版本不符"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :SUFeedURL' "${APP}/Contents/Info.plist")" == 'https://github.com/Lunomakes/clove/releases/latest/download/appcast.xml' ]] || fail "SUFeedURL 不符"
xcrun strip -S -x "${APP}/Contents/MacOS/Clove"
xattr -cr "${APP}"
codesign --force --deep --sign - --preserve-metadata=entitlements "${APP}"
codesign --verify --deep --strict "${APP}"
python3 -I tools/fork-release.py privacy "${APP}"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/clove-zh-release.XXXXXX")"
MOUNTED=0
cleanup() {
  if [[ "${MOUNTED}" == 1 ]]; then
    hdiutil detach "${WORK}/mount" >/dev/null || { echo "卸载失败：${WORK}/mount；保留临时目录" >&2; return; }
  fi
  rm -rf "${WORK}"
}
trap cleanup EXIT
mkdir -p dist "${WORK}/stage" "${WORK}/feed" "${WORK}/mount"
DMG="${ROOT}/dist/Clove-${VERSION}.dmg"
ditto "${APP}" "${WORK}/stage/Clove.app"
ln -s /Applications "${WORK}/stage/Applications"
hdiutil create -volname "Clove ${VERSION}" -srcfolder "${WORK}/stage" -ov -format UDZO -fs HFS+ "${DMG}"
hdiutil attach -readonly -nobrowse -mountpoint "${WORK}/mount" "${DMG}" >/dev/null
MOUNTED=1
codesign --verify --deep --strict "${WORK}/mount/Clove.app"
[[ "$(readlink "${WORK}/mount/Applications")" == /Applications ]] || fail "DMG 缺少 Applications 链接"
python3 -I tools/fork-release.py privacy "${WORK}/mount/Clove.app"
hdiutil detach "${WORK}/mount" >/dev/null
MOUNTED=0
cp "${DMG}" "${WORK}/feed/"
if [[ -n "${NOTES}" ]]; then
  python3 -I tools/notes-html.py "${NOTES}" > "${WORK}/feed/Clove-${VERSION}.html"
fi
"${SPARKLE_BIN}/generate_appcast" --account clove-zh --embed-release-notes \
  --download-url-prefix "https://github.com/Lunomakes/clove/releases/download/${TAG}/" \
  -o "${WORK}/appcast.xml" "${WORK}/feed"
python3 -I tools/fork-release.py appcast "${WORK}/appcast.xml" "${VERSION}" "${BUILD}"
cp "${WORK}/appcast.xml" dist/appcast.xml
SIGNATURE="$(python3 -I -c 'import sys, xml.etree.ElementTree as E; print(E.parse(sys.argv[1]).find("channel/item/enclosure").attrib["{http://www.andymatuschak.org/xml-namespaces/sparkle}edSignature"])' dist/appcast.xml)"
"${SPARKLE_BIN}/sign_update" --account clove-zh --verify "${DMG}" "${SIGNATURE}"
(cd dist && shasum -a 256 "$(basename "${DMG}")") > dist/checksums.txt
cat dist/checksums.txt
# Keep the tag bound to exactly the reviewed source, even if a build tool edited files.
[[ -z "$(git status --porcelain)" && "$(git rev-parse HEAD)" == "${SOURCE_COMMIT}" ]] || fail "构建期间源码发生改动，请检查后重试"
if [[ "${DRY_RUN}" == 1 ]]; then
  echo "dry-run 完成：${DMG}、${ROOT}/dist/checksums.txt、${ROOT}/dist/appcast.xml；未创建 tag、push 或 release。"
  exit 0
fi

git tag -a "${TAG}" "${SOURCE_COMMIT}" -m "Clove ${VERSION}"
git push origin main "${TAG}"
RELEASE_NOTES="${WORK}/notes.md"
if [[ -n "${NOTES}" ]]; then
  cp "${NOTES}" "${RELEASE_NOTES}"
else
  printf 'Clove %s\n' "${VERSION}" > "${RELEASE_NOTES}"
fi
gh release create "${TAG}" "${DMG}" dist/checksums.txt dist/appcast.xml \
  --repo Lunomakes/clove --title "Clove ${VERSION}" --notes-file "${RELEASE_NOTES}" --verify-tag
mkdir "${WORK}/download"
gh release download "${TAG}" --repo Lunomakes/clove --dir "${WORK}/download" \
  --pattern "$(basename "${DMG}")" --pattern checksums.txt --pattern appcast.xml
for asset in "$(basename "${DMG}")" checksums.txt appcast.xml; do
  LOCAL_SHA="$(shasum -a 256 "dist/${asset}" | cut -d ' ' -f 1)"
  REMOTE_SHA="$(shasum -a 256 "${WORK}/download/${asset}" | cut -d ' ' -f 1)"
  [[ "${LOCAL_SHA}" == "${REMOTE_SHA}" ]] || fail "发布后 SHA-256 不一致：${asset}"
done
echo "发布完成并核对下载 SHA-256：https://github.com/Lunomakes/clove/releases/tag/${TAG}"
