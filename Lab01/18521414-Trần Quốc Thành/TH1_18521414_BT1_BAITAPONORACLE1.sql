/*----- CÂU 1. Tạo user tên là BAITHI gồm có 4 table XE, TUYEN, KHACH, VEXE. 
Tạo khóa chính, khóa ngoại cho các table đó. -----*/

-- 1. Tạo user
ALTER SESSION SET "_ORACLE_SCRIPT" = true;

CREATE USER BaiTapCNTT1 IDENTIFIED BY "12345";

GRANT sysdba TO BaiTapCNTT1;

-- 2. Tạo bảng XE
CREATE TABLE BaiTapCNTT1.XE
(
    MAXE VARCHAR2(3) CONSTRAINT PK_XE PRIMARY KEY,
    BIENKS VARCHAR2(10),
    MATUYEN VARCHAR(4),
    SOGHET1 NUMBER,
    SOGHET2 NUMBER
)

-- 3. Tạo bảng TUYEN
CREATE TABLE BaiTapCNTT1.TUYEN
(
    MATUYEN VARCHAR(4) CONSTRAINT PK_TUYEN PRIMARY KEY,
    BENDAU VARCHAR(3) NOT NULL,
    BENCUOI VARCHAR(3) NOT NULL,
    GIATUYEN DECIMAL,
    NGXB DATE,
    TGDK NUMBER
)

-- 4. Tạo bảng HANHKHACH
CREATE TABLE BaiTapCNTT1.HANHKHACH
(
    MAHK VARCHAR(4) CONSTRAINT PK_HANHKHACH PRIMARY KEY,
    HOTEN VARCHAR(20),
    GIOITINH VARCHAR(3),
    CMND NUMBER(11)
)
 
-- 5. Tạo bảng VEXE
CREATE TABLE BaiTapCNTT1.VEXE
(
    MATUYEN VARCHAR(4),
    MAHK VARCHAR(4),
    NGMUA DATE,
    GIAVE DECIMAL,
    CONSTRAINT PK_VEXE PRIMARY KEY (MATUYEN, MAHK, NGMUA)
)

/*----- CÂU 2. Nhập liệu bảng cho 4 table như đề bài. -----*/

ALTER SESSION SET NLS_DATE_FORMAT = ' DD/MM/YY HH24:MI:SS ';

ALTER USER BaiTapCNTT1 QUOTA UNLIMITED ON USERS;

-- 1. Nhập liệu bảng XE
INSERT INTO BaiTapCNTT1.XE VALUES('X01', '52LD-4393', 'T11A', 20, 20);
INSERT INTO BaiTapCNTT1.XE VALUES('X02', '59LD-7247', 'T32D', 36, 36);
INSERT INTO BaiTapCNTT1.XE VALUES('X03', '55LD-6850', 'T06F', 15, 15);

-- 2. Nhập liệu bảng TUYEN
INSERT INTO BaiTapCNTT1.TUYEN VALUES('T11A', 'SG', 'DL', 210.000, '26/12/2016', 6);
INSERT INTO BaiTapCNTT1.TUYEN VALUES('T32D', 'PT', 'SG', 120.000, '30/12/2016', 4);
INSERT INTO BaiTapCNTT1.TUYEN VALUES('T06F', 'NT', 'DNG', 225.000, '02/01/2017', 7);

-- 3. Nhập liệu bảng HANHKHACH
INSERT INTO BaiTapCNTT1.HANHKHACH VALUES ('KH01', 'Lâm Văn Bền', 'Nam', 655615896);
INSERT INTO BaiTapCNTT1.HANHKHACH VALUES ('KH02', 'Dương Thị Lục', 'Nữ', 275648642);
INSERT INTO BaiTapCNTT1.HANHKHACH VALUES ('KH03', 'Hoàng Thanh Tùng', 'Nam', 456889143);

-- 4. Nhập liệu bảng VEXE
INSERT INTO BaiTapCNTT1.VEXE VALUES ('T11A', 'KH01', '20/12/2016', 210.000);
INSERT INTO BaiTapCNTT1.VEXE VALUES ('T32D', 'KH02', '25/12/2016', 144.000);
INSERT INTO BaiTapCNTT1.VEXE VALUES ('T06F', 'KH03', '30/12/2016', 270.000);

-- 5. Kiểm tra
SELECT * FROM BaiTapCNTT1.XE;
SELECT * FROM BaiTapCNTT1.TUYEN;
SELECT * FROM BaiTapCNTT1.HANHKHACH;
SELECT * FROM BaiTapCNTT1.VEXE;

-- 6. Thêm ràng buộc khóa ngoại
ALTER TABLE BaiTapCNTT1.XE ADD FOREIGN KEY (MATUYEN) REFERENCES BaiTapCNTT1.TUYEN(MATUYEN);
ALTER TABLE BaiTapCNTT1.VEXE ADD FOREIGN KEY (MATUYEN) REFERENCES BaiTapCNTT1.TUYEN(MATUYEN);
ALTER TABLE BaiTapCNTT1.VEXE ADD FOREIGN KEY (MAHK) REFERENCES BaiTapCNTT1.HANHKHACH(MAHK);

/*----- CÂU 3. Hiện thực ràng buộc toàn vẹn sau: Các tuyến xe có Thời gian dự kiến
lớn hơn 5 tiếng luôn có giá tuyến lớn hơn 200.000. -----*/
ALTER TABLE BaiTapCNTT1.TUYEN 
ADD CONSTRAINT CHECK_GIATUYEN CHECK((TGDK > 5 AND GIATUYEN > 200.000) OR TGDK <= 5);

-- Kiển tra
-- Thỏa -> Chèn thành công
INSERT INTO BaiTapCNTT1.TUYEN VALUES('T35D', 'PT', 'SG', 300.000, '30/12/2016', 4);
INSERT INTO BaiTapCNTT1.TUYEN VALUES('T65D', 'PT', 'SG', 100.000, '30/12/2016', 2);
INSERT INTO BaiTapCNTT1.TUYEN VALUES('T42D', 'PT', 'SG', 220.000, '30/12/2016', 5);
INSERT INTO BaiTapCNTT1.TUYEN VALUES('T01F', 'NT', 'DNG', 235.000, '02/01/2017', 6);

-- Không thỏa -> Chèn lỗi
INSERT INTO BaiTapCNTT1.TUYEN VALUES('T03F', 'NT', 'DNG', 125.000, '02/01/2017', 8);

-- Xóa dữ liệu vừa Test
DELETE FROM BaiTapCNTT1.TUYEN
WHERE MATUYEN IN ('T35D', 'T65D', 'T42D', 'T01F', 'T03F');

/*----- CÂU 4. Hiện thực ràng buộc toàn vẹn sau: Tuyến xe có ngày xuất bến từ 
ngày 29/12/2016 đến ngày 05/01/2017 sẽ có giá vé tăng 20%. -----*/


/*----- CÂU 5. Tìm tất cả các vé xe mua trong tháng 12, sắp xếp kết quả giảm dần theo giá vé. -----*/
SELECT * 
FROM BaiTapCNTT1.VEXE
WHERE EXTRACT( MONTH FROM NGMUA) = 12
ORDER BY GIAVE DESC;

/*----- CÂU 6. Tìm tuyến xe có số vé xe ít nhất trong năm 2016. -----*/
SELECT DISTINCT MATUYEN
FROM BaiTapCNTT1.VEXE 
WHERE EXTRACT(YEAR FROM NGMUA) = 2016
GROUP BY MATUYEN
HAVING COUNT(MATUYEN) <= ALL (
                                SELECT COUNT(MATUYEN)
                                FROM BaiTapCNTT1.VEXE
                                WHERE EXTRACT(YEAR FROM NGMUA) = 2016
                                GROUP BY MATUYEN
                             );

/*----- CÂU 7. Tìm tuyến xe có cả hành khách nam và hành khách nữ mua vé. -----*/
SELECT VEXE.MATUYEN
FROM BaiTapCNTT1.VEXE VEXE JOIN BaiTapCNTT1.HANHKHACH HK ON VEXE.MAHK = HK.MAHK
WHERE GIOITINH = 'Nam'
                    
INTERSECT
                    
SELECT VEXE.MATUYEN
FROM BaiTapCNTT1.VEXE VEXE JOIN BaiTapCNTT1.HANHKHACH HK ON VEXE.MAHK = HK.MAHK
WHERE GIOITINH = 'Nữ';

-- Kiểm tra
-- Thêm dữ liệu
INSERT INTO BaiTapCNTT1.VEXE VALUES ('T06F', 'KH02', '30/12/2016', 270.000);
-- Chạy lại sẽ được kết quả: Tuyến T06F có cả hành khách nam và nữ mua vé
-- Xóa dữ liệu vừa Test
DELETE FROM BaiTapCNTT1.VEXE
WHERE MATUYEN = 'T06F' AND MAHK = 'KH02';

/*----- CÂU 8. Tìm hành khách nữ đã từng mua vé tất cả các tuyến xe -----*/
SELECT *
FROM BaiTapCNTT1.HANHKHACH HK
WHERE GIOITINH = 'Nữ'
      AND NOT EXISTS (
                        SELECT *
                        FROM BaiTapCNTT1.TUYEN TUYEN 
                        WHERE NOT EXISTS (
                                            SELECT *
                                            FROM BaiTapCNTT1.VEXE VEXE
                                            WHERE VEXE.MATUYEN = TUYEN.MATUYEN
                                                  AND VEXE.MAHK = HK.MAHK
                                         )
                     );
                     
-- Thêm dữ liệu để Test
INSERT INTO BaiTapCNTT1.VEXE VALUES ('T06F', 'KH02', '30/12/2016', 270.000);
INSERT INTO BaiTapCNTT1.VEXE VALUES ('T11A', 'KH02', '30/12/2016', 210.000);

SELECT * FROM BaiTapCNTT1.VEXE;
-- Chạy lại ta được kết quả: HK02 đã mua vé của tất cả các tuyến
-- Xóa dữ liệu Test
DELETE FROM BaiTapCNTT1.VEXE
WHERE (MATUYEN = 'T11A' OR MATUYEN = 'T06F') AND MAHK = 'KH02';


-- CÁCH 2 - dùng COUNT
SELECT VEXE.MAHK
FROM BaiTapCNTT1.VEXE VEXE JOIN BaiTapCNTT1.HANHKHACH HK ON VEXE.MAHK = HK.MAHK
WHERE GIOITINH = 'Nữ'
GROUP BY VEXE.MAHK
HAVING COUNT(DISTINCT MATUYEN) = (
                                   SELECT COUNT(MATUYEN)
                                   FROM BaiTapCNTT1.TUYEN
                                 );                      
                        
-- CÁCH 3 - dùng NOT IN
SELECT *
FROM BaiTapCNTT1.HANHKHACH HK
WHERE GIOITINH = 'Nữ'
      AND MAHK NOT IN (
                       SELECT MAHK
                       FROM BaiTapCNTT1.TUYEN TUYEN 
                       WHERE MATUYEN NOT IN (
                                              SELECT MATUYEN
                                              FROM BaiTapCNTT1.VEXE VEXE
                                              WHERE VEXE.MATUYEN = TUYEN.MATUYEN
                                                    AND VEXE.MAHK = HK.MAHK
                                            )
                      );
                     