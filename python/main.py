import ccxt.async_support as ccxt
import asyncio
import time 

# --- 配置区域 ---
SYMBOL = 'BTCUSDT'  # 监控的交易对
THRESHOLD = 0.5      # 警报阈值：当价差百分比超过 0.5% 时触发
POLL_INTERVAL = 1    # 轮询间隔（秒）

async def monitor_basis():
    # 初始化两个交易所实例：一个看现货，一个看合约
    # binance: 现货
    # binanceusdm: U本位合约 (USD-M Futures)
    exchange_spot = ccxt.binance()
    exchange_perp = ccxt.binanceusdm()
    print(f"--- 开始监控 {SYMBOL} 期现价差 (阈值: {THRESHOLD}%) ---")
    try:
        while True:
            # 1. 并发获取数据，减少网络延迟造成的误差
            # 使用 asyncio.gather 同时发起两个 HTTP 请求
            tasks = [
                exchange_spot.fetch_ticker(SYMBOL),
                exchange_perp.fetch_ticker(SYMBOL)
            ]
            
            results = await asyncio.gather(*tasks)
            
            ticker_spot = results[0]
            ticker_perp = results[1]

            # 2. 提取最新成交价 (Last Price)
            price_spot = ticker_spot['last']
            price_perp = ticker_perp['last']

            # 3. 计算基差和百分比
            # 基差 = 合约价格 - 现货价格
            basis = price_perp - price_spot
            basis_percent = (basis / price_spot) * 100

            # 4. 格式化输出
            # 红色或绿色高亮显示，取决于是否有利可图
            log_msg = (
                f"现货: {price_spot:.2f} | "
                f"合约: {price_perp:.2f} | "
                f"基差: {basis:.2f} ({basis_percent:.4f}%)"
            )

            if abs(basis_percent) >= THRESHOLD:
                print(f"🚨 [机会触发] {log_msg} <--- 关注！！")
                # 在这里可以添加发送 Telegram/Discord 通知的代码
            else:
                # 只有在价差正常时才打印普通日志，避免刷屏（可选）
                print(f"[监控中] {log_msg}")

            # 休息一下，避免触发 API 频率限制
            await asyncio.sleep(POLL_INTERVAL)

    except KeyboardInterrupt:
        print("\n监控已停止。")
    except Exception as e:
        print(f"发生错误: {e}")
    finally:
        # 必须关闭连接
        await exchange_spot.close()
        await exchange_perp.close()
        
## --- 代码测试区域 ---
## --- 主程序入口 ---
if __name__ == '__main__':
    # monitor_basis()
    asyncio.run(monitor_basis())
