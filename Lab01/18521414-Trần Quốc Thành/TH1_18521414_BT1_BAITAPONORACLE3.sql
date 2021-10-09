/*----- CÂU 1. Tạo user tên BAITHI gồm có 4 table HANGHANGKHONG, CHUYENBAY, NHANVIEN,
PHANCONG. Tạo khóa chính, khóa ngoại cho các table đó.  -----*/

-- Tạo user
ALTER SESSION SET "_ORACLE_SCRIPT" = true;

CREATE USER BaiTapCNTT3 IDENTIFIED BY "12345";

GRANT sysdba TO BaiTapCNTT3;

-- 1. Tạo bảng HANGHANGKHONG
CREATE TABLE BaiTapCNTT3.HANGHANGKHONG
(
	MAHANG VARCHAR(2) CONSTRAINT PK_HANGHANGKHONG PRIMARY KEY,
	TENHANG VARCHAR(50),
	NGTL DATE,
	DUONGBAY NUMBER
);

-- 2. Tạo bảng CHUYENBAY
CREATE TABLE BaiTapCNTT3.CHUYENBAY 
(
	MACB VARCHAR(5) CONSTRAINT PK_CHUYENBAY PRIMARY KEY,
	MAHANG VARCHAR(2),
	XUATPHAT VARCHAR(20),
	DIEMDEN VARCHAR(20),
	BATDAU DATE,
	TGBAY DECIMAL(18, 1)
);

-- 3. Tạo bảng NHANVIEN
CREATE TABLE BaiTapCNTT3.NHANVIEN
(
	MANV VARCHAR(4) CONSTRAINT PK_NHANVIEN PRIMARY KEY,
	HOTEN VARCHAR(50),
	GIOITINH VARCHAR(5),
	NGSINH DATE,
	NGVL DATE,
	CHUYENMON VARCHAR(20)
);

-- 4. Tạo bảng PHANCONG
CREATE TABLE BaiTapCNTT3.PHANCONG
(
	MACB VARCHAR(5),
	MANV VARCHAR(4),
	NHIEMVU VARCHAR(30),
	CONSTRAINT PK_PHANCONG PRIMARY KEY (MACB,MANV)
);

/*----- CÂU 2. Nhập dữ liệu cho 4 table như đề bài. -----*/
ALTER SESSION SET NLS_DATE_FORMAT = ' DD/MM/YY HH24:MI:SS ';

ALTER USER BaiTapCNTT3 QUOTA UNLIMITED ON USERS;

-- 1. Nhập liệu bảng HANGHANGKHONG
INSERT INTO BaiTapCNTT3.HANGHANGKHONG VALUES ('VN', 'Vietnam Airlines', '15/01/1956', 52);
INSERT INTO BaiTapCNTT3.HANGHANGKHONG VALUES ('VJ', 'Vietjet Air', '25/12/2011', 33);
INSERT INTO BaiTapCNTT3.HANGHANGKHONG VALUES ('BL', 'Jetstar Pacific Airlines', '01/12/1990', 13);

-- 2. Nhập liệu bảng CHUYENBAY
INSERT INTO BaiTapCNTT3.CHUYENBAY VALUES ('VN550', 'VN', 'TP.HCM', N'Singapore', '20/12/2015 13:15', 2);
INSERT INTO BaiTapCNTT3.CHUYENBAY VALUES ('VJ331', 'VJ', 'Đà Nẵng', N'Vinh', '28/12/2015 22:30', 1);
INSERT INTO BaiTapCNTT3.CHUYENBAY VALUES ('BL696', 'BL', 'TP.HCM', N'Đà Lạt', '24/12/2015 06:00', 0.5);

-- 3. Nhập liệu bảng NHANVIEN
INSERT INTO BaiTapCNTT3.NHANVIEN VALUES	('NV01', N'Lâm Văn Bền', N'Nam', '10/09/1978', '05/06/2000', N'Phi công');
INSERT INTO BaiTapCNTT3.NHANVIEN VALUES ('NV02', N'Dương Thị Lục', N'Nữ', '22/03/1989', '12/11/2013', N'Tiếp viên');
INSERT INTO BaiTapCNTT3.NHANVIEN VALUES ('NV03', N'Hoàng Thanh Tùng', N'Nam', '29/07/1983', '11/04/2007', N'Tiếp viên');

-- 4. Nhập liệu bảng PHANCONG
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('VN550', 'NV01', N'Cơ trưởng');
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('VN550', 'NV02', N'Tiếp viên');
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('BL696', 'NV03', N'Tiếp viên trưởng');

-- Thêm khóa ngoại
ALTER TABLE BaiTapCNTT3.CHUYENBAY ADD FOREIGN KEY (MAHANG) REFERENCES BaiTapCNTT3.HANGHANGKHONG(MAHANG);
ALTER TABLE BaiTapCNTT3.PHANCONG ADD FOREIGN KEY (MACB) REFERENCES BaiTapCNTT3.CHUYENBAY(MACB);
ALTER TABLE BaiTapCNTT3.PHANCONG ADD FOREIGN KEY (MANV) REFERENCES BaiTapCNTT3.NHANVIEN(MANV);

-- Kiểm tra
SELECT * FROM BaiTapCNTT3.HANGHANGKHONG;
SELECT * FROM BaiTapCNTT3.CHUYENBAY;
SELECT * FROM BaiTapCNTT3.NHANVIEN;
SELECT * FROM BaiTapCNTT3.PHANCONG;


/*----- CÂU 3. Hiện thực ràng buộc toàn vẹn sau: Chuyên môn của nhân viên 
chỉ được nhận giá trị là ‘Phi công’ hoặc ‘Tiếp viên’.  -----*/
ALTER TABLE BaiTapCNTT3.NHANVIEN 
ADD CONSTRAINT CHECK_CHUYENMON CHECK(CHUYENMON = 'Phi công' 
                                        OR CHUYENMON = 'Tiếp viên');

-- Thêm dữ liệu để kiểm tra
-- Báo lỗi
INSERT INTO BaiTapCNTT3.NHANVIEN 
VALUES	('NV06', N'Lâm Quốc A', N'Nam', '10/09/1978', '05/06/2000', N'Phi công trưởng');

-- Thành công
INSERT INTO BaiTapCNTT3.NHANVIEN 
VALUES	('NV07', N'Lâm Trần B', N'Nam', '10/09/1978', '05/06/2000', N'Tiếp viên');
INSERT INTO BaiTapCNTT3.NHANVIEN 
VALUES	('NV08', N'Lâm Quốc C', N'Nam', '10/09/1978', '05/06/2000', N'Phi công');

-- Xóa dữ liệu đã thêm
DELETE FROM BaiTapCNTT3.NHANVIEN
WHERE MANV = 'NV07' OR MANV = 'NV08';

/*----- CÂU 4. Hiện thực ràng buộc toàn vẹn sau: Ngày bắt đầu chuyến bay luôn 
lớn hơn ngày thành lập hãng hàng không quản lý chuyến bay đó.  -----*/


/*----- CÂU 5. Tìm tất cả các nhân viên có sinh nhật trong tháng 07.  -----*/
SELECT * 
FROM BaiTapCNTT3.NHANVIEN
WHERE EXTRACT (MONTH FROM NGSINH) = 07;

/*----- CÂU 6. Tìm chuyến bay có số nhân viên nhiều nhất.  -----*/
SELECT MACB
FROM BaiTapCNTT3.PHANCONG 
GROUP BY MACB
HAVING COUNT(MANV) >= ALL (
                            SELECT COUNT(MANV)
                            FROM BaiTapCNTT3.PHANCONG
                            GROUP BY MACB
                          );  

/*----- CÂU 7. Với mỗi hãng hàng không, thống kê số chuyến bay có điểm xuất phát
là ‘Đà Nẵng’ và có số nhân viên được phân công ít hơn 2.  -----*/
SELECT HHK.MAHANG, COUNT(DISTINCT PC.MACB) AS SOCHUYENBAY
FROM BaiTapCNTT3.HANGHANGKHONG HHK 
     JOIN BaiTapCNTT3.CHUYENBAY CB ON HHK.MAHANG = CB.MAHANG
     JOIN BaiTapCNTT3.PHANCONG PC ON CB.MACB = PC.MACB   
WHERE XUATPHAT = 'Đà Nẵng'
        AND PC.MACB IN (
                          SELECT PC1.MACB -- Tìm  các CB có số NV <= 2 của mỗi hãng
                          FROM BaiTapCNTT3.HANGHANGKHONG HHK1 
                               JOIN BaiTapCNTT3.CHUYENBAY CB1 ON HHK1.MAHANG = CB1.MAHANG
                               JOIN BaiTapCNTT3.PHANCONG PC1 ON CB1.MACB = PC1.MACB   
                          WHERE XUATPHAT = 'Đà Nẵng'
                          GROUP BY HHK1.MAHANG, PC1.MACB
                          HAVING COUNT(MANV) <= 2
                        )
GROUP BY HHK.MAHANG;

-- Thêm dữ liệu để kiểm tra
-- Thêm chuyến bay xuất phát ở Đà Nẵng
INSERT INTO BaiTapCNTT3.CHUYENBAY VALUES ('VJ344', 'VJ', 'Đà Nẵng', N'Vinh', '28/12/2015 22:30', 1);
INSERT INTO BaiTapCNTT3.CHUYENBAY VALUES ('VJ522', 'VJ', 'Đà Nẵng', N'Vinh', '28/12/2015 22:30', 1);
INSERT INTO BaiTapCNTT3.CHUYENBAY VALUES ('BL335', 'BL', 'Đà Nẵng', N'Vinh', '28/12/2015 22:30', 1);

-- Thêm phân công cho các chuyến đó
-- 3 NV
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('VJ331', 'NV01', N'Cơ trưởng');
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('VJ331', 'NV02', N'Tiếp viên');
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('VJ331', 'NV03', N'Tiếp viên');

-- 1 NV
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('VJ522', 'NV01', N'Cơ trưởng');

-- 2 NV
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('VJ344', 'NV01', N'Cơ trưởng');
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('VJ344', 'NV02', N'Tiếp viên');

-- 1 NV
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('BL335', 'NV01', N'Cơ trưởng');

-- In ra
SELECT HHK.MAHANG, PC.MACB, PC.MANV
FROM BaiTapCNTT3.HANGHANGKHONG HHK JOIN BaiTapCNTT3.CHUYENBAY CB 
        ON HHK.MAHANG = CB.MAHANG
     JOIN BaiTapCNTT3.PHANCONG PC ON CB.MACB = PC.MACB   
WHERE XUATPHAT = 'Đà Nẵng';

-- Chạy lại có KQ: VJ có 2 (VJ522, VJ334), BL có 1 (BL335
-- Xóa dữ liệu vừa thêm
DELETE FROM BaiTapCNTT3.PHANCONG
WHERE MACB IN ('VJ344', 'BL335', 'VJ331', 'VJ522');

DELETE FROM BaiTapCNTT3.CHUYENBAY
WHERE MACB IN ('VJ344', 'BL335', 'VJ522');

/*----- CÂU 8. Tìm nhân viên được phân công tham gia tất cả các chuyến bay.  -----*/
SELECT *
FROM BaiTapCNTT3.NHANVIEN NV
WHERE NOT EXISTS (
                    SELECT *
                    FROM BaiTapCNTT3.CHUYENBAY CB
                    WHERE NOT EXISTS (
                                        SELECT *
                                        FROM BaiTapCNTT3.PHANCONG PC
                                        WHERE PC.MACB = CB.MACB
                                              AND PC.MANV = NV.MANV
                                      )
                 );

-- Thêm dữ liệu để kiểm tra
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('VJ331', 'NV01', N'Tiếp viên trưởng');
INSERT INTO BaiTapCNTT3.PHANCONG VALUES ('BL696', 'NV01', N'Tiếp viên');


SELECT * FROM BaiTapCNTT3.PHANCONG;
-- Chạy lại được kết quả: NV01 được phân công tất cả chuyến bay
-- Xóa dữ liệu Test
DELETE FROM BaiTapCNTT3.PHANCONG
WHERE (MACB = 'VJ331' OR MACB = 'BL696') AND MANV = 'NV01';


-- CÁCH 2 - dùng COUNT
SELECT MANV
FROM BaiTapCNTT3.PHANCONG
GROUP BY MANV
HAVING COUNT(DISTINCT MACB) = (
                                SELECT COUNT(MACB)
                                FROM BaiTapCNTT3.CHUYENBAY
                              );

-- CÁCH 3 -- dùng NOT IN
SELECT *
FROM BaiTapCNTT3.NHANVIEN NV
WHERE MANV NOT IN (
                    SELECT MANV
                    FROM BaiTapCNTT3.CHUYENBAY CB
                    WHERE MACB NOT IN (
                                        SELECT MACB
                                        FROM BaiTapCNTT3.PHANCONG PC
                                        WHERE PC.MACB = CB.MACB
                                               AND PC.MANV = NV.MANV
                                      )
                  );
     
