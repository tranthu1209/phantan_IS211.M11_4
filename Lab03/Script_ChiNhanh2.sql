------------------------- Tại MÁY 2 ---------------------------------
-- 1. Trên SQL Plus đăng nhập /as sysdba, sau đó tạo user để insert DL
----- 1.1 Tạo một user CN2 với password là CN2
CREATE USER CN2 IDENTIFIED BY CN2;

----- 1.2 Gán quyền connect, dba cho tài khoản CN2
GRANT CONNECT, DBA TO CN2;


-- 2. Mở SQL Dev, tạo connect CHI NHANH 2 dùng user CN2
----- 2.1 Chạy lệnh tạo bảng
CREATE TABLE CN2.SACH 
(
    MaSach char(5) PRIMARY KEY,
    TenSach varchar2(50),
    NgayXB date,
    TacGia varchar2(50),
    GiaTien number,
    NhaXuatBan varchar2(50),
    LanIn number
);

CREATE TABLE CN2.CHINHANH 
(
    MaChiNhanh char(4) PRIMARY KEY,
    TenChiNhanh varchar2(60),
    SoDT char(10) NOT NULL UNIQUE
);

CREATE TABLE CN2.KHOSACH_QLKHO  
(
    MaChiNhanh char(4),
    MaSach char(5), 
    SoLuong number,
    NgayCapNhat date,
    CONSTRAINT PK_KSQL  PRIMARY KEY (MaChiNhanh, MaSach, NgayCapNhat)
);

CREATE TABLE CN2.KHOSACH_NVBH 
(
    MaChiNhanh char(4),
    MaSach char(5),
    TinhTrang varchar(10),
    KhuyenMai number,
    CONSTRAINT PK_KSNVBH  PRIMARY KEY (MaChiNhanh, MaSach)
);

CREATE TABLE CN2.NHANVIEN 
(
    MaNV char(4) PRIMARY KEY,
    TenNV varchar2(50),
    DiaChi varchar2(60),
    SoDT char(10) UNIQUE,
    Luong number,
    MaChiNhanh char(4)
);

----- 2.2 Chạy lệnh Insert DL
INSERT INTO CN2.SACH VALUES ('Book1','SpyxFamily T.6',TO_DATE('29/10/2021','dd/mm/yyyy'),'Endou Tatsuya',25000 ,'Kim Dong',1);
INSERT INTO CN2.SACH VALUES ('Book2','S. Family T.6 L',TO_DATE('29/10/2021','dd/mm/yyyy'),'Endou Tatsuya',45000 ,'Kim Dong',1);
INSERT INTO CN2.SACH(MaSach, TenSach,TacGia, GiaTien, NhaXuatBan, LanIn)
	VALUES ('Book3','Th. Lũng B.H ','Agatha Christie',120000,'Tre',1);
INSERT INTO CN2.SACH VALUES ('Book4','Black Jack 3',TO_DATE('25/10/2021','dd/mm/yyyy'),'Osamu Tezuka',30000 ,'Tre',1);
INSERT INTO CN2.SACH VALUES ('Book5','One Piece 90',TO_DATE('11/10/2021','dd/mm/yyyy'),'Eiichiro Oda',19500 ,'Kim Dong',2);

---Insert Chi Nhanh---

INSERT INTO CN2.CHINHANH VALUES ('CN02','Quan 10, TPHCM',0907979816);

---INSERT KHOSACH_QLKHO---

INSERT INTO CN2.KHOSACH_QLKHO VALUES ('CN02','Book1',0,TO_DATE('29/10/2021','dd/mm/yyyy'));
INSERT INTO CN2.KHOSACH_QLKHO VALUES ('CN02','Book2',0,TO_DATE('29/10/2021','dd/mm/yyyy'));
INSERT INTO CN2.KHOSACH_QLKHO VALUES ('CN02','Book4',180,TO_DATE('30/10/2021','dd/mm/yyyy'));
INSERT INTO CN2.KHOSACH_QLKHO VALUES ('CN02','Book5',170,TO_DATE('30/10/2021','dd/mm/yyyy'));

---INSERT KHOSACH_NVBH---

INSERT INTO CN2.KHOSACH_NVBH VALUES ('CN02','Book1','Het Hang',10);
INSERT INTO CN2.KHOSACH_NVBH VALUES ('CN02','Book2','Het Hang',0);
INSERT INTO CN2.KHOSACH_NVBH VALUES ('CN02','Book4','Con Hang',10);
INSERT INTO CN2.KHOSACH_NVBH VALUES ('CN02','Book5','Con Hang',15);

---INSERT NHANVIEN---

INSERT INTO CN2.NHANVIEN VALUES ('NV01','Dang Vu Phuong Uyen','TP.HCM','0773915608', 3750000,'CN02');
INSERT INTO CN2.NHANVIEN VALUES ('NV02','Tran Nhat Linh','Gia Lai','0355428421', 3750000,'CN02');
INSERT INTO CN2.NHANVIEN VALUES ('NV05','Huynh Kim Phat ','TP.HCM','0944651790', 3750000,'CN02');
    
----- 2.2 Chạy lệnh ràng buộc khóa ngoại
/* Bảng KHOSACH_QLKHO */
ALTER TABLE CN2.KHOSACH_QLKHO
ADD CONSTRAINT FK_KHOSACH_QLKHO_MaChiNhanh FOREIGN KEY (MaChiNhanh)
REFERENCES CN2.CHINHANH(MaChiNhanh);

ALTER TABLE CN2.KHOSACH_QLKHO
ADD CONSTRAINT FK_KHOSACH_QLKHO_MaSach FOREIGN KEY (MaSach)
REFERENCES CN2.SACH(MaSach);

/* Bảng KHOSACH_NVBH */
ALTER TABLE CN2.KHOSACH_NVBH
ADD CONSTRAINT FK_KHOSACH_NVBH_MaChiNhanh FOREIGN KEY (MaChiNhanh)
REFERENCES CN2.CHINHANH(MaChiNhanh);

ALTER TABLE CN2.KHOSACH_NVBH
ADD CONSTRAINT FK_KHOSACH_NVBH_MaSach FOREIGN KEY (MaSach)
REFERENCES CN2.SACH(MaSach);

/* Bảng CN2.NHANVIEN */
ALTER TABLE CN2.NHANVIEN
ADD CONSTRAINT FK_NHANVIEN_MaChiNhanh FOREIGN KEY (MaChiNhanh)
REFERENCES CN2.CHINHANH(MaChiNhanh);

----- 2.2 Chạy lệnh ràng buộc CHECK
ALTER TABLE CN2.KHOSACH_NVBH
ADD CONSTRAINT CHECK_KHOSACH_NVBH_TinhTrang CHECK(TinhTrang = 'Con Hang' OR TinhTrang = 'Het Hang');


-- III. Trên SQL Plus đăng nhập /as sysdba, sau đó tạo user và phân quyền
----- GiamDoc 
    CREATE USER GiamDoc IDENTIFIED BY GiamDoc;

	GRANT CONNECT TO GiamDoc; 
	GRANT SELECT ON CN2.SACH TO GiamDoc; 
    	GRANT SELECT ON CN2.CHINHANH TO GiamDoc;
    	GRANT SELECT ON CN2.KHOSACH_QLKHO TO GiamDoc;
    	GRANT SELECT ON CN2.KHOSACH_NVBH TO GiamDoc;
    	GRANT SELECT ON CN2.NHANVIEN TO GiamDoc;

----- QuanLyKho
    	CREATE USER QuanLyKho IDENTIFIED BY QuanLyKho;

	GRANT CONNECT TO QuanLyKho;
	GRANT SELECT ON CN2.KHOSACH_QLKHO TO QuanLyKho;
    	GRANT SELECT ON CN2.SACH TO QuanLyKho;

----- NhanVien
	CREATE USER NhanVien IDENTIFIED BY NhanVien;
    
    	GRANT CONNECT TO NhanVien;
    	GRANT SELECT ON CN2.SACH TO NhanVien; 
	GRANT SELECT ON CN2.KHOSACH_NVBH TO NhanVien;
	GRANT CREATE DATABASE LINK TO NhanVien;
    
-- IV. Trên SQL Plus tạo Database link đến user NhanVien Chi nhánh 1
CONNECT NhanVien/NhanVien;
CREATE DATABASE LINK NV_dblink CONNECT TO NhanVien IDENTIFIED BY NhanVien 
    USING 'nv_sn';

-- V. Thực hiện các câu truy vấn
/* Query 6: Tài khoản nhân viên: Đưa ra thông tin mã sách, tên sách, phần trăm
khuyến mãi trung bı̀nh, tổng số chi nhánh phân phối sách của những sách thuộc
nhà xuất bản ‘Kim Dong’. */

CONNECT NhanVien/NhanVien;



SELECT MaSach, TenSach, AVG(KhuyenMai) AS KhuyenMaiTB, COUNT(DISTINCT MaChiNhanh) AS TongSoChiNhanh
FROM (
SELECT S2.MaSach, TenSach, NhaXuatBan, MaChiNhanh, KhuyenMai
FROM CN2.SACH S2 JOIN CN2.KHOSACH_NVBH NVBH2 ON S2.MaSach = NVBH2.MaSach
UNION
SELECT S1.MaSach, TenSach, NhaXuatBan, MaChiNhanh, KhuyenMai
FROM CN1.SACH@NV_dblink S1 JOIN CN1.KHOSACH_NVBH@NV_dblink NVBH1
ON S1.MaSach = NVBH1.MaSach
)
WHERE NhaXuatBan = 'Kim Dong'
GROUP BY MaSach, TenSach;


