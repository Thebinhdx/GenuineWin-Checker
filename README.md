<h1 align="center"> GenuineWinOffice-Checker </h1>

<p align="center"> English: A tool for scanning and assessing the integrity of Windows and Office licenses using Batch. Replicates the methods used to detect KMS, HWID, KMS38, Ohook cracks and system tampering. </p>

<p align="center"> Vietnamese: Công cụ quét và đánh giá tính toàn vẹn bản quyền Windows và Office bằng Batch. Tái hiện phương pháp giám định phát hiện vết bẻ khóa KMS, HWID, KMS38, Ohook và can thiệp hệ thống. </p>

<hr>

## ⚠️ IMPORTANT NOTICE / LƯU Ý QUAN TRỌNG TRƯỚC KHI TẢI

> [!WARNING]
> **FALSE POSITIVE ALERT / CẢNH BÁO NHẬN DIỆN NHẦM**
> 
> Because this tool queries deep system components (Registry, WMI, and Task Scheduler) to audit licenses, some antivirus software (including Windows Defender) may flag the `.bat` file as suspicious. 
> 
> *Vì công cụ này cần truy vấn sâu vào hệ thống (Registry, WMI, Task Scheduler) để giám định bản quyền, một số trình diệt virus (bao gồm Windows Defender) có thể cảnh báo nhầm file `.bat` này là mã độc.*

> [!NOTE]
>
> The software's conclusions are not always accurate, so double-check carefully before concluding.
>
> *Kết luận của phần mềm không đảm bảo lúc nào cũng đúng nên kiểm tra lại cẩn thận trước khi kết luận.*
---

### ❓ FAQ / Câu hỏi thường gặp

| Issue / Vấn đề | Explanation / Giải thích |
| :--- | :--- |
| **Is it safe?** <br> *(Có an toàn không?)* | **100% Safe.** The source code is entirely open-source, written in plain Batch. It is **Read-Only**—it does not collect, modify, or send any data to external servers. <br><br> * **100% An toàn.** Mã nguồn mở hoàn toàn bằng Batch thô. Công cụ chỉ **Đọc thông tin** — không thu thập, sửa đổi hay gửi bất kỳ dữ liệu nào ra ngoài.* |
| **Why the Antivirus warning?** <br> *(Tại sao bị báo virus?)* | The script uses commands like `reg query`, `sc query`, and `schtasks` to detect hidden crack tools. Security engines often flag these administrative commands as "suspicious heuristics" in `.bat` scripts. <br><br> *Script sử dụng các lệnh như `reg query`, `sc query`, và `schtasks` để tìm vết công cụ crack ngầm. Trình quét virus thường đánh dấu các lệnh quản trị này là nghi vấn.* |
| **How to run it safely?** <br> *(Làm sao để chạy an toàn?)* | You can right-click the `.bat` file, select **Edit** to audit every single line of code yourself before executing it with Administrator privileges. <br><br> *Bạn có thể click chuột phải vào file `.bat`, chọn **Edit** để tự kiểm tra từng dòng code trước khi chạy bằng quyền Administrator.* |

---

### 💡 Quick Troubleshooting / Khắc phục nhanh nếu bị chặn

1. **If Windows Defender blocks the download:** Click `Keep anyway` (Vẫn giữ lại) hoặc `Run anyway` (Vẫn chạy) nếu màn hình SmartScreen xuất hiện.
2. **Review Code:** We highly encourage you to review the raw code here on GitHub to verify its complete safety. *(Chúng tôi khuyến khích bạn tự xem lại toàn bộ mã nguồn công khai ngay tại đây để tự kiểm chứng).*
