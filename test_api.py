#!/usr/bin/env python3
"""
钱包API测试脚本 - 测试网环境
无需前端，直接测试后端所有功能
"""

import requests
import json
import time
from datetime import datetime

# ============================================
# 配置
# ============================================

API_URL = "http://localhost:8888"
API_KEY = "testnet_api_key_change_in_production"

HEADERS = {
    "Authorization": API_KEY,
    "Content-Type": "application/json"
}

# ============================================
# 辅助函数
# ============================================

def print_section(title):
    """打印分隔线"""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")

def print_response(response):
    """打印HTTP响应"""
    print(f"状态码: {response.status_code}")
    try:
        print(f"响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
    except:
        print(f"响应: {response.text}")

def test_api(name, method, endpoint, data=None, auth=True):
    """统一的API测试函数"""
    print(f"🧪 测试: {name}")
    
    url = f"{API_URL}{endpoint}"
    headers = HEADERS if auth else {"Content-Type": "application/json"}
    
    try:
        if method == "GET":
            response = requests.get(url, headers=headers)
        elif method == "POST":
            response = requests.post(url, headers=headers, json=data)
        elif method == "DELETE":
            response = requests.delete(url, headers=headers)
        else:
            print(f"❌ 不支持的HTTP方法: {method}")
            return False
        
        print_response(response)
        
        if response.status_code < 400:
            print("✅ 测试通过")
            return True
        else:
            print("⚠️  测试失败")
            return False
            
    except Exception as e:
        print(f"❌ 请求异常: {e}")
        return False

# ============================================
# 主测试流程
# ============================================

def main():
    print("🚀 开始钱包API测试网测试")
    print(f"时间: {datetime.now()}")
    print(f"API地址: {API_URL}")
    
    results = []
    
    # 1. 健康检查
    print_section("1. 健康检查 (无需认证)")
    results.append(test_api("健康检查", "GET", "/api/health", auth=False))
    
    time.sleep(1)
    
    # 2. 创建钱包
    print_section("2. 创建钱包")
    wallet_data = {
        "name": "test_wallet_py",
        "quantum_safe": False
    }
    results.append(test_api("创建钱包", "POST", "/api/wallets", data=wallet_data))
    
    time.sleep(1)
    
    # 3. 列出所有钱包
    print_section("3. 列出所有钱包")
    results.append(test_api("列出钱包", "GET", "/api/wallets"))
    
    time.sleep(1)
    
    # 4. 查询余额
    print_section("4. 查询余额 (Sepolia测试网)")
    results.append(test_api("查询余额", "GET", "/api/wallets/test_wallet_py/balance?network=sepolia"))
    
    time.sleep(1)
    
    # 5. 备份钱包
    print_section("5. 备份钱包")
    results.append(test_api("备份钱包", "GET", "/api/wallets/test_wallet_py/backup"))
    
    time.sleep(1)
    
    # 6. 查询交易历史
    print_section("6. 查询交易历史")
    results.append(test_api("交易历史", "GET", "/api/wallets/test_wallet_py/history"))
    
    time.sleep(1)
    
    # 7. 系统指标
    print_section("7. 系统指标")
    results.append(test_api("系统指标", "GET", "/api/metrics"))
    
    time.sleep(1)
    
    # 8. 发送交易 (可选，需要测试币)
    print_section("8. 发送交易 (需要先获取测试币)")
    print("⚠️  跳过发送交易测试 - 需要先从水龙头获取测试币")
    # tx_data = {
    #     "to_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    #     "amount": "0.001",
    #     "network": "sepolia"
    # }
    # results.append(test_api("发送交易", "POST", "/api/wallets/test_wallet_py/send", data=tx_data))
    
    time.sleep(1)
    
    # 9. 删除钱包
    print_section("9. 删除钱包")
    results.append(test_api("删除钱包", "DELETE", "/api/wallets/test_wallet_py"))
    
    # 最终统计
    print_section("测试总结")
    total = len(results)
    passed = sum(results)
    failed = total - passed
    
    print(f"总测试数: {total}")
    print(f"✅ 通过: {passed}")
    print(f"❌ 失败: {failed}")
    print(f"成功率: {passed/total*100:.1f}%")
    
    if failed == 0:
        print("\n🎉 所有测试通过！")
    else:
        print(f"\n⚠️  有 {failed} 个测试失败")

if __name__ == "__main__":
    main()

