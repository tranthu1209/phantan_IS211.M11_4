------------------------- Tại MÁY 1 ---------------------------------
-- 1. Trên SQL Plus đăng nhập /as sysdba, sau đó tạo user để insert DL
----- 1.1 Tạo một user CN1 với password là CN1
CREATE USER CN1 IDENTIFIED BY CN1;

----- 1.2 Gán quyền connect, dba cho tài khoản CN1
GRANT CONNECT, DBA TO CN1;


-- 2. Mở SQL Dev, tạo connect CHI NHANH 1 dùng user CN1
----- 2.1 Chạy lệnh tạo bảng
CREATE TABLE CN1.SACH 
(
    MaSach char(5) PRIMARY KEY,
    TenSach varchar2(50),
    NgayXB date,
    TacGia varchar2(50),
    GiaTien number,
    NhaXuatBan varchar2(50),
    LanIn number
);

CREATE TABLE CN1.CHINHANH 
(
    MaChiNhanh char(4) PRIMARY KEY,
    TenChiNhanh varchar2(60),
    SoDT char(10) NOT NULL UNIQUE
);

CREATE TABLE CN1.KHOSACH_QLKHO  
(
    MaChiNhanh char(4),
    MaSach char(5), 
    SoLuong number,
    NgayCapNhat date,
    CONSTRAINT PK_KSQL  PRIMARY KEY (MaChiNhanh, MaSach, NgayCapNhat)
);

CREATE TABLE CN1.KHOSACH_NVBH 
(
    MaChiNhanh char(4) ,
    MaSach char(5),
    TinhTrang varchar(10),
    KhuyenMai number,
    CONSTRAINT PK_KSNVBH  PRIMARY KEY (MaChiNhanh, MaSach)
);

CREATE TABLE CN1.NHANVIEN 
(
    MaNV char(4) PRIMARY KEY,
    TenNV varchar2(50),
    DiaChi varchar2(60),
    SoDT char(10) UNIQUE,
    Luong number,
    MaChiNhanh char(4)
);


----- 2.2 Chạy lệnh Insert DL
INSERT INTO CN1.SACH VALUES ('Book1','SpyxFamily T.6',TO_DATE('29/10/2021','dd/mm/yyyy'),'Endou Tatsuya',25000 ,'Kim Dong',1);
INSERT INTO CN1.SACH VALUES ('Book2','S. Family T.6 L',TO_DATE('29/10/2021','dd/mm/yyyy'),'Endou Tatsuya',45000 ,'Kim Dong',1);
INSERT INTO CN1.SACH(MaSach, TenSach,TacGia, GiaTien, NhaXuatBan, LanIn)
	VALUES ('Book3','Th. Lũng B.H ','Agatha Christie',120000,'Tre',1);
INSERT INTO CN1.SACH VALUES ('Book4','Black Jack 3',TO_DATE('25/10/2021','dd/mm/yyyy'),'Osamu Tezuka',30000 ,'Tre',1);
INSERT INTO CN1.SACH VALUES ('Book5','One Piece 90',TO_DATE('11/10/2021','dd/mm/yyyy'),'Eiichiro Oda',19500 ,'Kim Dong',2);


INSERT INTO CN1.CHINHANH VALUES ('CN01','Hoan Kiem,Ha Noi',0939013914);

INSERT INTO CN1.KHOSACH_QLKHO VALUES ('CN01','Book1',0,TO_DATE('29/10/2021','dd/mm/yyyy'));   
INSERT INTO CN1.KHOSACH_QLKHO VALUES ('CN01','Book3',510,TO_DATE('30/10/2021','dd/mm/yyyy'));
INSERT INTO CN1.KHOSACH_QLKHO VALUES ('CN01','Book5',100,TO_DATE('30/10/2021','dd/mm/yyyy'));


INSERT INTO CN1.KHOSACH_NVBH VALUES ('CN01','Book1','Het Hang',0);   
INSERT INTO CN1.KHOSACH_NVBH VALUES ('CN01','Book3','Con Hang',20);
INSERT INTO CN1.KHOSACH_NVBH VALUES ('CN01','Book5','Con Hang',20);

INSERT INTO CN1.NHANVIEN VALUES ('NV03','Tran Quoc Thanh','Binh Dinh',0379868677,4250000,'CN01');
INSERT INTO CN1.NHANVIEN VALUES ('NV04','Nguyen Hoang Quoc','Dong Nai',0388240570,4250000,'CN01');
INSERT INTO CN1.NHANVIEN VALUES ('NV06','Phan Vy Hao','Tay Ninh',0969574973,4250000,'CN01');
    
----- 2.2 Chạy lệnh ràng buộc khóa ngoại
/* Bảng KHOSACH_QLKHO */
ALTER TABLE CN1.KHOSACH_QLKHO
ADD CONSTRAINT FK_KHOSACH_QLKHO_MaChiNhanh FOREIGN KEY (MaChiNhanh)
REFERENCES CN1.CHINHANH(MaChiNhanh);

ALTER TABLE CN1.KHOSACH_QLKHO
ADD CONSTRAINT FK_KHOSACH_QLKHO_MaSach FOREIGN KEY (MaSach)
REFERENCES CN1.SACH(MaSach);

/* Bảng KHOSACH_NVBH */
ALTER TABLE CN1.KHOSACH_NVBH
ADD CONSTRAINT FK_KHOSACH_NVBH_MaChiNhanh FOREIGN KEY (MaChiNhanh)
REFERENCES CN1.CHINHANH(MaChiNhanh);

ALTER TABLE CN1.KHOSACH_NVBH
ADD CONSTRAINT FK_KHOSACH_NVBH_MaSach FOREIGN KEY (MaSach)
REFERENCES CN1.SACH(MaSach);

/* Bảng CN1.NHANVIEN */
ALTER TABLE CN1.NHANVIEN
ADD CONSTRAINT FK_NHANVIEN_MaChiNhanh FOREIGN KEY (MaChiNhanh)
REFERENCES CN1.CHINHANH(MaChiNhanh);

----- 2.2 Chạy lệnh ràng buộc CHECK
ALTER TABLE CN1.KHOSACH_NVBH
ADD CONSTRAINT CHECK_KHOSACH_NVBH_TinhTrang CHECK(TinhTrang = 'Con Hang' OR TinhTrang = 'Het Hang');


-- III. Trên SQL Plus đăng nhập /as sysdba, sau đó tạo user và phân quyền
----- GiamDoc 
    CREATE USER GiamDoc IDENTIFIED BY GiamDoc;

	GRANT CONNECT TO GiamDoc; 
	GRANT SELECT ON CN1.SACH TO GiamDoc; 
    	GRANT SELECT ON CN1.CHINHANH TO GiamDoc;
    	GRANT SELECT ON CN1.KHOSACH_QLKHO TO GiamDoc;
    	GRANT SELECT ON CN1.KHOSACH_NVBH TO GiamDoc;
    	GRANT SELECT ON CN1.NHANVIEN TO GiamDoc;
	GRANT CREATE DATABASE LINK TO GiamDoc; 

----- QuanLyKho
    	CREATE USER QuanLyKho IDENTIFIED BY QuanLyKho;

	GRANT CONNECT TO QuanLyKho;
	GRANT SELECT ON CN1.KHOSACH_QLKHO TO QuanLyKho;
    	GRANT SELECT ON CN1.SACH TO QuanLyKho;

----- NhanVien
	CREATE USER NhanVien IDENTIFIED BY NhanVien;
    
    	GRANT CONNECT TO NhanVien;
    	GRANT SELECT ON CN1.SACH TO NhanVien; 
	GRANT SELECT ON CN1.KHOSACH_NVBH TO NhanVien;
    	GRANT CREATE DATABASE LINK TO NhanVien; 

-- IV. Trên SQL Plus tạo Database link đến user GiamDoc Chi nhánh 2
CONNECT GiamDoc/GiamDoc;
CREATE DATABASE LINK GD_dblink CONNECT TO GiamDoc IDENTIFIED BY GiamDoc 
    USING 'gd_sn';

CONNECT NhanVien/NhanVien;
CREATE DATABASE LINK NV_dblink CONNECT TO NhanVien IDENTIFIED BY NhanVien 
    USING 'nv_sn';

-- V. Thực hiện các câu truy vấn
/* Query 1. Tài khoản nhân viên: Đưa ra thông tin sách với tı̀nh trạng ‘Con Hang’ của
tất cả các chi nhánh. Thông tin hiển thị (MaChiNhanh, MaSach, TenSach) */
CONNECT NhanVien/NhanVien;

SELECT NVBH1.MaChiNhanh, S1.MaSach, S1.TenSach
FROM CN1.KHOSACH_NVBH NVBH1 JOIN CN1.SACH S1
	ON NVBH1.MaSach = S1.MaSach
WHERE TinhTrang = 'Con Hang'
UNION
SELECT NVBH2.MaChiNhanh, S2.MaSach, S2.TenSach
FROM CN2.KHOSACH_NVBH@NV_dblink NVBH2 JOIN CN2.SACH@NV_dblink S2
	ON NVBH2.MaSach = S2.MaSach
WHERE TinhTrang = 'Con Hang';

/* Query 2. Tài khoản giám đốc: Tı̀m sách với tı̀nh trạng ‘Con Hang’ và số lượng sách
trong kho lớn hơn 135 tại tất cả chi nhánh. Thông tin hiển thị (MaSach, TenSach) */
CONNECT GiamDoc/GiamDoc;

SELECT S1.MaSach, S1.TenSach
FROM CN1.KHOSACH_NVBH NVBH1 JOIN CN1.SACH S1
	ON NVBH1.MaSach = S1.MaSach
     JOIN CN1.KHOSACH_QLKHO QL1 ON QL1.MaSach = S1.MaSach
WHERE TinhTrang = 'Con Hang' AND SoLuong > 135
UNION
SELECT S2.MaSach, S2.TenSach
FROM CN2.KHOSACH_NVBH@GD_dblink NVBH2 JOIN CN2.SACH@GD_dblink S2
	ON NVBH2.MaSach = S2.MaSach
     JOIN CN2.KHOSACH_QLKHO@GD_dblink QL2 ON QL2.MaSach = S2.MaSach
WHERE TinhTrang = 'Con Hang' AND SoLuong > 135;

/* Query 4. Tài khoản giám đốc: Đưa ra thông tin sách (Mã sách, tên sách) được phân
phối đến tất cả chi nhánh với tình trạng hết hàng.  */

SELECT S1.MaSach, S1.TenSach
FROM CN1.SACH S1
WHERE NOT EXISTS (
			   SELECT * 
			   FROM CN1.CHINHANH C1 
                           WHERE NOT EXISTS (
                                              SELECT *
                                              FROM CN1.KHOSACH_NVBH NVBH1
                                              WHERE TinhTrang = 'Het Hang'
							AND NVBH1.MaChiNhanh = C1.MaChiNhanh
							AND NVBH1.MaSach = S1.MaSach
                                            )
                     	)
INTERSECT
SELECT S2.MaSach, S2.TenSach
FROM CN2.SACH@GD_dblink S2
WHERE NOT EXISTS (
			   SELECT * 
			   FROM CN2.CHINHANH@GD_dblink C2 
                           WHERE NOT EXISTS (
                                              SELECT *
                                              FROM CN2.KHOSACH_NVBH@GD_dblink NVBH2
                                              WHERE TinhTrang = 'Het Hang'
							AND NVBH2.MaChiNhanh = C2.MaChiNhanh
							AND NVBH2.MaSach = S2.MaSach
                                            )
                     	);



/* Query 5. Tài khoản giám đốc: Tìm sách được phân phối tại chi nhánh 1 nhưng
không có tại chi nhánh 2.  */

SELECT MaSach
FROM CN1.KHOSACH_NVBH
MINUS
SELECT MaSach
FROM CN2.KHOSACH_NVBH@GD_dblink;


/* Query 3. Tài khoản quản lý kho: Đưa ra thông tin sách gồm tên sách, ngày xuất
bản, tác giả, giá tiền, số lượng, lần in, ngày nhập với những sách của chi nhánh mı̀nh
quản lý của nhà xuất bản ‘Tre’.  */
CONNECT QuanLyKho/QuanLyKho;

SELECT S1.TenSach, S1.NgayXB, S1.TacGia, S1.GiaTien, NVBH1.SoLuong, S1.LanIn, NVBH1.NgayCapNhaT
FROM CN1.KHOSACH_QLKHO NVBH1 JOIN CN1.SACH S1 ON NVBH1.MaSach = S1.MaSach
WHERE NhaXuatBan = 'Tre';



