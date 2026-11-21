@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo ============================================
echo    LiNSO ARCHIVE  -  发布更新
echo ============================================
echo.
echo [1/2] 生成网页并推送到 GitHub Pages...
call npx hexo g -d
if errorlevel 1 (
  echo.
  echo [失败] 部署没成功。
  echo        最常见原因是网络：请检查 VPN 是否开着，然后重新双击本文件。
  echo.
  pause
  exit /b 1
)
echo.
echo [2/2] 备份源码到 source 分支...
git add -A
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "update" >nul
  git push origin source
) else (
  echo 源码没有变化，跳过备份。
)
echo.
echo ============================================
echo    完成！等 1-2 分钟后访问：
echo    https://linsovo.github.io
echo ============================================
echo.
pause
