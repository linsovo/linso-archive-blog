@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo ============================================
echo    LiNSO ARCHIVE  -  本地预览
echo ============================================
echo.
echo 预览地址： http://localhost:4000
echo 浏览器会自动打开，没打开就手动访问上面的地址。
echo.
echo 提示：
echo   - 改 .md 文章：保存后刷新浏览器即可
echo   - 改 .yml 配置：需要关掉这个窗口重新双击
echo.
echo 关闭预览：直接关掉这个黑窗口，或按 Ctrl+C
echo ============================================
echo.
start "" http://localhost:4000
call npx hexo server -p 4000
pause
