-------------------------------------------------------------------------------
-- V. Thực hiện Trigger, Procedure, Function phân tán
-- 5.1 Thực hiện Trigger (Chạy trên Máy A, tài khoản CNA)
---- 5.1.1 Trigger: Ngày đăng ký dịch vụ không được trước ngày đăng ký phòng 
--                      NGAYDK_DV >= NGAYDK_P
/*
- Bối cảnh: PHIEU_DK_P, DK_DV

- Nội dung: Với mọi pdk_p thuộc PHIEU_DK_P, tồn tại dk_dv thuộc DK_DV: 
    pdk_p.MAPDK = dk_dv.MAPDK và NGAYDK_DV >= NGAYDK_P 
                
- Bảng tầm ảnh hưởng:
          Thêm	 Xóa	Sửa
DK_DV	    +	  -	     +(NGAYDK_DV, MAPDK)
PHIEU_DK_P  -	  -	     +(NGAYDK_P)

*/
-- Trigger INSERT, UPDATE trên bảng DK_DV
CREATE OR REPLACE TRIGGER INSERT_UPDATE_DK_DV
AFTER INSERT OR UPDATE
ON CNA.DK_DV FOR EACH ROW
DECLARE
    v_ngaydk_p DATE;
BEGIN
    SELECT NGAYDK_P INTO v_ngaydk_p
    FROM CNA.PHIEU_DK_P PDK_P
    WHERE PDK_P.MAPDK = :NEW.MAPDK;
    
    IF (:NEW.NGAYDK_DV < v_ngaydk_p) THEN
        RAISE_APPLICATION_ERROR(-20100, 'Ngày đăng ký dịch vụ không được 
            trước ngày đăng ký phòng');
    END IF;    
END;

-------------------------------------------
-- Trigger UPDATE trên bảng PHIEU_DK_P
CREATE OR REPLACE TRIGGER UPDATE_DK_P
AFTER UPDATE
ON CNA.PHIEU_DK_P FOR EACH ROW
DECLARE
    v_ngaydk_dv DATE;
BEGIN
    SELECT NGAYDK_DV INTO v_ngaydk_dv
    FROM CNA.DK_DV DK_DV
    WHERE DK_DV.MAPDK = :NEW.MAPDK;
    
    IF (:NEW.NGAYDK_P > v_ngaydk_dv) THEN
        RAISE_APPLICATION_ERROR(-20100, 'Ngày đăng ký dịch vụ không được 
            trước ngày đăng ký phòng');
    END IF;    
END;

---------------------------------------
---- 5.1.2 Kiểm tra Trigger
-- Trigger INSERT, UPDATE trên bảng DK_DV
-- Kiểm tra DL đang có
SELECT PDK_P.MAPDK, NGAYDK_P, NGAYDK_DV
FROM CNA.PHIEU_DK_P PDK_P JOIN CNA.DK_DV DK_DV ON PDK_P.MAPDK = DK_DV.MAPDK;

-- TH UPDATE
-- TH lỗi: PDK03: NGAYDK_P = 10-02-2007, NGAYDK_DV = 08-03-2007
--          -> Sửa NGAYDK_DV = 08-03-2006
UPDATE CNA.DK_DV
SET NGAYDK_DV = '08-03-2006'
WHERE MAPDK = 'PDK03';

-- TH thành công: PDK03: NGAYDK_P = 10-02-2007, NGAYDK_DV = 08-03-2007
--          -> Sửa NGAYDK_DV = 12-02-2007
UPDATE CNA.DK_DV
SET NGAYDK_DV = '12-02-2007'
WHERE MAPDK = 'PDK03';

-- Trả DL lại trạng thái ban đầu khi chưa kiểm tra Trigger
UPDATE CNA.DK_DV
SET NGAYDK_DV = '08-03-2007'
WHERE MAPDK = 'PDK03';

-- TH INSERT
-- TH lỗi: PDK03: NGAYDK_P = 10-02-2007
--          -> Thêm DK_DV có NGAYDK_DV = 08-02-2007
insert into CNA.DK_DV values('DK_DV77','DV1','PDK03','08-02-2007','CNA');

-- TH thành công: PDK03: NGAYDK_P = 10-02-2007
--          -> Thêm DK_DV có NGAYDK_DV = 19-02-2007
insert into CNA.DK_DV values('DK_DV77','DV1','PDK03','19-02-2007','CNA');

-- Trả DL lại trạng thái ban đầu khi chưa kiểm tra Trigger
DELETE FROM CNA.DK_DV
WHERE MADK_DV = 'DK_DV77';

----------------------------------------------------
-- Trigger UPDATE trên bảng PHIEU_DK_P
-- TH lỗi:  PDK03: NGAYDK_P = 10-02-2007, NGAYDK_DV = 08-03-2007
--          -> Sửa NGAYDK_P = 10-03-2007
UPDATE CNA.PHIEU_DK_P
SET NGAYDK_P = '10-03-2007'
WHERE MAPDK = 'PDK03';

-- TH Thành công:  PDK03: NGAYDK_P = 10-02-2007, NGAYDK_DV =  08-03-2007
--          -> Sửa NGAYDK_P = 07-03-2007
UPDATE CNA.PHIEU_DK_P
SET NGAYDK_P = '07-03-2007'
WHERE MAPDK = 'PDK03';

---------------------------------------------------
-- Trả DL lại trạng thái ban đầu khi chưa kiểm tra Trigger
UPDATE CNA.PHIEU_DK_P
SET NGAYDK_P = '10-02-2007'
WHERE MAPDK = 'PDK03';

--------------------------------------
-- 5.2 Thực hiện Procedure
/* Nhập vào mã dịch vụ in ra tổng số lần khách hàng đăng ký sử dụng dịch vụ đó 
và thông tin MAKH, TENKH, số lần đăng ký của từng khách hàng. */
set serveroutput on size 30000;
CONNECT GiamDoc/GiamDoc;

---- Tạo Procedure
CREATE OR REPLACE PROCEDURE PROC_DV( madv_in IN char)
AS
    var_tendv varchar2(40);
    var_makh char(4);
    var_tenkh varchar2(40);
    var_solan number;
    var_tongsolandk number;
    cur_makh char(4);
    CURSOR CURA IS SELECT DISTINCT KH.MAKH
                  FROM CNA.KHACHHANG KH JOIN CNA.PHIEU_DK_P PDK ON KH.MAKH = PDK.MAKH
                    JOIN CNA.DK_DV DK_DV ON DK_DV.MAPDK = PDK.MAPDK
                  WHERE DK_DV.MADV = madv_in;
    CURSOR CURB IS SELECT DISTINCT KH.MAKH
                  FROM CNB.KHACHHANG@GD_dblink KH JOIN CNB.PHIEU_DK_P@GD_dblink PDK 
                        ON KH.MAKH = PDK.MAKH
                    JOIN CNB.DK_DV@GD_dblink DK_DV ON DK_DV.MAPDK = PDK.MAPDK
                  WHERE DK_DV.MADV = madv_in;
BEGIN
    -- Lấy thông tin DV và tính tổng số lần DV đó được đăng ký
    SELECT TENDV, COUNT(*) INTO var_tendv, var_tongsolandk
    FROM 
    (
        SELECT *
        FROM CNA.DICHVU DVU JOIN CNA.DK_DV DK_DV ON DVU.MADV = DK_DV.MADV
        WHERE DK_DV.MADV = madv_in
        UNION
        SELECT *
        FROM CNB.DICHVU@GD_dblink DVU JOIN CNB.DK_DV@GD_dblink DK_DV 
            ON DVU.MADV = DK_DV.MADV
        WHERE DK_DV.MADV = madv_in
    )
    GROUP BY TENDV;
    
    DBMS_OUTPUT.PUT_LINE('================= PROC_DV ===================');
    DBMS_OUTPUT.PUT_LINE('** THÔNG TIN ĐĂNG KÝ CỦA DỊCH VỤ: '|| var_tendv);
    DBMS_OUTPUT.PUT_LINE('**   MÃ DỊCH VỤ: '|| madv_in);
    DBMS_OUTPUT.PUT_LINE('**   TÊN DỊCH VỤ: '|| var_tendv);
    DBMS_OUTPUT.PUT_LINE('**   TỔNG SỐ LẦN ĐĂNG KÝ: '|| var_tongsolandk);
    
    DBMS_OUTPUT.PUT_LINE('============== Chi nhánh Thủ Đức ================');
    OPEN CURA;
    LOOP
        FETCH CURA INTO cur_makh;
        EXIT WHEN CURA%NOTFOUND;

        -- Lấy thông tin KH đăng ký
        SELECT  KH.MAKH, TENKH, COUNT(*) INTO var_makh, var_tenkh, var_solan
        FROM CNA.KHACHHANG KH JOIN CNA.PHIEU_DK_P PDK ON KH.MAKH = PDK.MAKH
                    JOIN CNA.DK_DV DK_DV ON DK_DV.MAPDK = PDK.MAPDK
        WHERE DK_DV.MADV = madv_in AND KH.MAKH = cur_makh
        GROUP BY KH.MAKH, TENKH;
        
        -- In kết quả
        DBMS_OUTPUT.PUT_LINE('MÃ KHÁCH HÀNG: ' || var_makh);
        DBMS_OUTPUT.PUT_LINE('TÊN KHÁCH HÀNG: '|| var_tenkh);
        DBMS_OUTPUT.PUT_LINE('SỐ LẦN ĐĂNG KÝ: '|| var_solan);
        DBMS_OUTPUT.PUT_LINE('  =========================================');
    END LOOP;
    CLOSE CURA; 
    
    DBMS_OUTPUT.PUT_LINE('=============== Chi nhánh Quận 1 ================');
    OPEN CURB;
    LOOP
        FETCH CURB INTO cur_makh;
        EXIT WHEN CURB%NOTFOUND;

        -- Lấy thông tin KH đăng ký
        SELECT  KH.MAKH, TENKH, COUNT(*) INTO var_makh, var_tenkh, var_solan
        FROM CNB.KHACHHANG@GD_dblink KH JOIN CNA.PHIEU_DK_P@GD_dblink PDK 
                ON KH.MAKH = PDK.MAKH
            JOIN CNA.DK_DV@GD_dblink DK_DV ON DK_DV.MAPDK = PDK.MAPDK
        WHERE DK_DV.MADV = madv_in AND KH.MAKH = cur_makh
        GROUP BY KH.MAKH, TENKH;
        
        -- In kết quả
        DBMS_OUTPUT.PUT_LINE('MÃ KHÁCH HÀNG: ' || var_makh);
        DBMS_OUTPUT.PUT_LINE('TÊN KHÁCH HÀNG: '|| var_tenkh);
        DBMS_OUTPUT.PUT_LINE('SỐ LẦN ĐĂNG KÝ: '|| var_solan);
        DBMS_OUTPUT.PUT_LINE('  =========================================');
    END LOOP;
    CLOSE CURB; 
END;

---- Thực thi Procedure
BEGIN
    PROC_DV('DV2');
END;

--------------------------------------
-- 5.3 Thực hiện Function
/* Viết hàm tính tổng doanh thu trong năm*/
--- Tạo Func
CREATE OR REPLACE FUNCTION TinhDoanhThu(var_year IN number)
RETURN number
AS
    var_doanhthu number;
BEGIN
    SELECT SUM(TONGTIEN) INTO var_doanhthu
    FROM 
    (
        SELECT TONGTIEN
        FROM CNA.HOADON_NV
        WHERE EXTRACT(YEAR FROM NGAYTHANHTOAN) = var_year
        UNION
        SELECT TONGTIEN
        FROM CNB.HOADON_NV@GD_dblink
        WHERE EXTRACT(YEAR FROM NGAYTHANHTOAN) = var_year
    );
    
    RETURN var_doanhthu;
END;

--- Thực thi Func
DECLARE
    var_nam number;
BEGIN
    var_nam := 2011;   
    DBMS_OUTPUT.PUT_LINE('Tổng doanh thu năm ' || var_nam || ' của cả 2 chi nhánh là : '
        || TinhDoanhThu(var_nam) || ' VNĐ'); 
END;
