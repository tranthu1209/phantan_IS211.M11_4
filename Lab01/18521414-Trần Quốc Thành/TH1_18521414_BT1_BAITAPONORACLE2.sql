/*----- CÂU 1. Tạo user tên BAITHI gồm có 4 table USER, CHANNEL, VIDEO, SHARE. Tạo khóa chính,
khóa ngoại cho các table đó. -----*/
-- Tạo user
ALTER SESSION SET "_ORACLE_SCRIPT" = true;

CREATE USER BaiTapCNTT2 IDENTIFIED BY "12345";

GRANT sysdba TO BaiTapCNTT2;

-- 1. Tạo bảng USER_NEW
CREATE TABLE BaiTapCNTT2.USER_NEW
(
    U_ID VARCHAR(3) CONSTRAINT PK_USER_NEW PRIMARY KEY,
    USERNAME VARCHAR(20),
    PASS VARCHAR(20),
    REGDAY DATE,
    NATIONALITY VARCHAR(20) 
);

-- 2. Tạo bảng CHANNEL
CREATE TABLE BaiTapCNTT2.CHANNEL
(
    CHANNELID VARCHAR(4) CONSTRAINT PK_CHANNELID PRIMARY KEY,
    CNAME VARCHAR(20),
    SUBSCRIBES NUMBER,
    OWNNER VARCHAR(3),
    CREATED DATE
);

-- 3. Tạo bảng VIDEO
CREATE TABLE BaiTapCNTT2.VIDEO
(
    VIDEOID VARCHAR(7) CONSTRAINT PK_VIDEO PRIMARY KEY,
    TITLE VARCHAR(100),
    DURATION NUMBER,
    AGE NUMBER
);

-- 4. Tạo bảng SHARE_NEW
CREATE TABLE BaiTapCNTT2.SHARE_NEW
(
    VIDEOID VARCHAR(7),
    CHANNELID VARCHAR(4),
    CONSTRAINT PK_SHARE_NEW PRIMARY KEY (VIDEOID, CHANNELID)
);

/*----- CÂU 2.Nhập dữ liệu cho 4 table như đề bài. -----*/

ALTER SESSION SET NLS_DATE_FORMAT = ' DD/MM/YY HH24:MI:SS ';

ALTER USER BaiTapCNTT2 QUOTA UNLIMITED ON USERS;

-- 1. Nhập liệu bảng USER_NEW
INSERT INTO BaiTapCNTT2.USER_NEW VALUES('001', 'faptv', '123456abc', '01/01/2014', 'Việt Nam');
INSERT INTO BaiTapCNTT2.USER_NEW VALUES('002', 'kemxoitv', '@147869iii', '05/06/2015', 'Campuchia');
INSERT INTO BaiTapCNTT2.USER_NEW VALUES('003', 'openshare', 'qwertyuiop', '12/05/2009', 'Việt Nam');

-- 2. Nhập liệu bảng CHANNEL
INSERT INTO BaiTapCNTT2.CHANNEL VALUES('C120', 'FAP TV', 2343, '001', '02/01/2014');
INSERT INTO BaiTapCNTT2.CHANNEL VALUES('C905', 'Kem xôi TV', 1032, '002', '09/07/2015');
INSERT INTO BaiTapCNTT2.CHANNEL VALUES('C357', 'OpenShare Cáfe', 5064, '003', '10/12/2010');

-- 3. Nhập liệu bảng VIDEO
INSERT INTO BaiTapCNTT2.VIDEO VALUES('V100229', 'FAPtv Cơm Nguội Tập 41 - Đột Nhập', 469, 18);
INSERT INTO BaiTapCNTT2.VIDEO VALUES('V211002', 'Kem xôi: Tập 31 -  Mẩy Kool tình yêu của anh', 312, 16);
INSERT INTO BaiTapCNTT2.VIDEO VALUES('V400002', 'Nơi tình yêu kết thúc - Hoàng Tuấn', 378, 0);

-- 4. Nhập liệu bảng SHARE_NEW
INSERT INTO BaiTapCNTT2.SHARE_NEW VALUES('V100229', 'C905');
INSERT INTO BaiTapCNTT2.SHARE_NEW VALUES('V211002', 'C120');
INSERT INTO BaiTapCNTT2.SHARE_NEW VALUES('V400002', 'C357');

-- Thêm khóa ngoại
ALTER TABLE BaiTapCNTT2.CHANNEL ADD FOREIGN KEY (OWNNER) REFERENCES BaiTapCNTT2.USER_NEW(U_ID);
ALTER TABLE BaiTapCNTT2.SHARE_NEW ADD FOREIGN KEY (VIDEOID) REFERENCES BaiTapCNTT2.VIDEO(VIDEOID);
ALTER TABLE BaiTapCNTT2.SHARE_NEW ADD FOREIGN KEY (CHANNELID) REFERENCES BaiTapCNTT2.CHANNEL(CHANNELID);

-- Kiểm tra
SELECT * FROM BaiTapCNTT2.USER_NEW;
SELECT * FROM BaiTapCNTT2.CHANNEL;
SELECT * FROM BaiTapCNTT2.VIDEO;
SELECT * FROM BaiTapCNTT2.SHARE_NEW;

/*----- CÂU 3. Hiện thực ràng buộc toàn vẹn sau: Ngày đăng ký được mặc định là ngày hiện tại.  -----*/
CREATE OR REPLACE TRIGGER USER_NEW_REGDAY
BEFORE INSERT ON BaiTapCNTT2.USER_NEW
FOR EACH ROW
BEGIN
    :NEW.REGDAY := SYSDATE;
END;

-- Thêm dữ liệu để kiểm tra
INSERT INTO BaiTapCNTT2.USER_NEW VALUES('006', 'vtv', '123456abc', '01/01/2014', 'Việt Nam');

-- In kết quả
SELECT *
FROM BaiTapCNTT2.USER_NEW
WHERE U_ID = '006';

-- Xóa dữ liệu đã thêm
DELETE FROM BaiTapCNTT2.USER_NEW
WHERE U_ID = '006';

/*----- CÂU 4. Hiện thực ràng buộc toàn vẹn sau: Ngày tạo kênh luôn lớn hơn hoặc
bằng ngày đăng ký của người dùng sở hữu kênh đó.  -----*/


/*----- CÂU 5. Tìm tất cả các video có giới hạn độ tuổi từ 16 trở lên.  -----*/
SELECT *
FROM BaiTapCNTT2.VIDEO
WHERE AGE >= 16;

/*----- CÂU 6. Tìm kênh có số người theo dõi nhiều nhất.  -----*/
SELECT *
FROM BaiTapCNTT2.CHANNEL 
WHERE OWNNER >= ALL (
                       SELECT OWNNER
                       FROM BaiTapCNTT2.CHANNEL
                     );

/*----- CÂU 7. Với mỗi video có giới hạn độ tuổi là 18, thống kê số kênh đã chia sẻ.  -----*/
SELECT VIDEO.VIDEOID, COUNT(CHANNELID) AS COUNT_CHANNEL_SHARED
FROM BaiTapCNTT2.VIDEO VIDEO JOIN baiTapCNTT2.SHARE_NEW SHARE_NEW 
        ON VIDEO.VIDEOID = SHARE_NEW.VIDEOID
WHERE AGE >= 18
GROUP BY VIDEO.VIDEOID;

/*----- CÂU 8. Tìm video được tất cả các kênh chia sẻ.  -----*/
SELECT *
FROM BaiTapCNTT2.VIDEO VIDEO
WHERE NOT EXISTS (
                    SELECT *
                    FROM BaiTapCNTT2.CHANNEL CHANNEL
                    WHERE NOT EXISTS (
                                        SELECT *
                                        FROM BaiTapCNTT2.SHARE_NEW SHARE_NEW
                                        WHERE SHARE_NEW.VIDEOID= VIDEO.VIDEOID
                                              AND SHARE_NEW.CHANNELID = CHANNEL.CHANNELID
                                      )
                 );

-- Thêm dữ liệu để kiểm tra
INSERT INTO BaiTapCNTT2.SHARE_NEW VALUES('V100229', 'C120');
INSERT INTO BaiTapCNTT2.SHARE_NEW VALUES('V100229', 'C357');

SELECT * FROM BaiTapCNTT2.SHARE_NEW;
-- Chạy lại được kết quả: V100229 được tất cả các kênh chia sẻ
-- Xóa dữ liệu Test
DELETE FROM BaiTapCNTT2.SHARE_NEW
WHERE (CHANNELID = 'C120' OR CHANNELID = 'C357') AND VIDEOID = 'V100229';


-- CÁCH 2 - dùng COUNT
SELECT VIDEOID
FROM BaiTapCNTT2.SHARE_NEW
GROUP BY VIDEOID
HAVING COUNT(DISTINCT CHANNELID) = (
                                       SELECT COUNT(CHANNELID)
                                       FROM BaiTapCNTT2.CHANNEL
                                   );

-- CÁCH 3 -- dùng NOT IN
SELECT *
FROM BaiTapCNTT2.VIDEO VIDEO
WHERE VIDEOID NOT IN (
                        SELECT VIDEOID
                        FROM BaiTapCNTT2.CHANNEL CHANNEL
                        WHERE CHANNELID NOT IN (
                                                SELECT CHANNELID
                                                FROM BaiTapCNTT2.SHARE_NEW SHARE_NEW
                                                WHERE SHARE_NEW.VIDEOID= VIDEO.VIDEOID
                                                      AND SHARE_NEW.CHANNELID = CHANNEL.CHANNELID
                                                )
                     );
                 
                 