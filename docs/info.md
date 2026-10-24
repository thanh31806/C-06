
## How it works
 
Thiết kế này là một khối phần cứng số hoạt động như một bộ giám sát tín hiệu. Nó nhận vào một dòng dữ liệu 8 bit(sample) và 1 giá trị ngưỡng 8 bit (thresh hold).Mạch chia dòng thành các cửa sổ có độ dài 256 chu kì clock. Trong mỗi cửa sổ mạch đếm số lượng mẫu có giá trị lớn hơn ngưỡng. Khi kết thúc(đủ 256 chu kì ) kết quả chốt vào thanh ghi và một xung báo hiệu phát ra trong đúng 1 chu kì. Sau đó mạch bắt đầu cửa sổ mới mà không có chu kì nghỉ

## How to test
Testbench kiểm tra các trường hợp biên quan trọng:
- Sự kiện rơi đúng vào chu kì 1,255,256
- Trường hợp mẫu bằng ngưỡng
- Tất cả mẫu đều vượt ngưỡng
- Kiểm tra cửa sổ mới bắt đầu khi cửa sổ cũ kết thúc
