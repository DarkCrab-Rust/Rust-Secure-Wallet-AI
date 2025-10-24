@echo off
echo Testing server health...
curl http://localhost:8888/health
echo.
echo Testing complete.
pause
