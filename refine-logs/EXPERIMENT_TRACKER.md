# Experiment Tracker: B-Spline Probe

| Run ID | Milestone | Purpose | System / Variant | Split | Metrics | Priority | Status | Notes |
|--------|-----------|---------|------------------|-------|---------|----------|--------|-------|
| R001 | M0 | sanity | B-spline fitting (scipy) | 合成信号 | 拟合误差 | MUST | TODO | 验证scipy B-spline API |
| R002 | M0 | sanity | REC/CPOI/LCA 计算 | 合成信号 | 指标值范围 | MUST | TODO | 检查指标数值合理性 |
| R003 | M0 | sanity | 可视化pipeline | 合成信号 | 热力图可读性 | MUST | TODO | matplotlib + seaborn |
| R004 | M1 | baseline | 小波检测 (db4) | 合成信号 | 检测率 | MUST | TODO | pywt库 |
| R005 | M1 | baseline | 梯度分析 | 合成信号 | 检测率 | MUST | TODO | numpy gradient |
| R006 | M1 | baseline | SIREN+WIRE训练 | Kodak24 | PSNR/SSIM | MUST | TODO | 1GPU×12h, 3seeds |
| R007 | M2 | main | B1: 合成信号实验 | SIREN | ROC AUC | MUST | TODO | 100 signals |
| R008 | M2 | main | B2: 定位对比 | B-spline/Wavelet/Gradient | Kodak24 | IoU | MUST | TODO | 24 images |
| R009 | M2 | main | B4: 跨架构 | SIREN/WIRE/FINER | Jaccard | MUST | TODO | 复用R006 |
| R010 | M3 | decision | B3: 修复闭环 | 诊断 vs 随机 | Kodak24×6 | ΔPSNR | MUST | TODO | 1GPU×8h |
| R011 | M3 | appendix | 指标互补性 | B-spline metrics | Kodak24 | 相关系数 | NICE | TODO | |
| R012 | M4 | polish | 可视化图表 | — | — | — | MUST | TODO | |
| R013 | M4 | appendix | 超参敏感性 | B-spline k/n | Kodak24 | IoU方差 | NICE | TODO | |
| R014 | M4 | polish | 论文撰写 | — | — | — | MUST | TODO | |
