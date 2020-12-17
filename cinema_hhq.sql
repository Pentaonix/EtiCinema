-- phpMyAdmin SQL Dump
-- version 4.9.6
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 16, 2020 at 02:25 AM
-- Server version: 8.0.21
-- PHP Version: 7.1.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cinema_hhq`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `cap_do_khach_hang` (IN `id_kh` INT)  NO SQL
BEGIN
	DECLARE diem_tich_luy int;
    set diem_tich_luy = `tinh_tien_khach_hang`(id_kh)/1000;
    UPDATE khach_hang set khach_hang.diemtichluy = diem_tich_luy where khach_hang.idkh = id_kh;
    IF diem_tich_luy >= 3000 THEN
    	UPDATE khach_hang set khach_hang.capdo = 'VIP' where khach_hang.idkh = id_kh;
    ELSEIF diem_tich_luy >= 1000 THEN
    	UPDATE khach_hang set khach_hang.capdo = 'A' where khach_hang.idkh = id_kh;
    ELSEIF diem_tich_luy >= 500 THEN
    	UPDATE khach_hang set khach_hang.capdo = 'B' where khach_hang.idkh = id_kh;
    ELSEIF diem_tich_luy >= 250 THEN
    	UPDATE khach_hang set khach_hang.capdo = 'C' where khach_hang.idkh = id_kh;
    ELSE
    	UPDATE khach_hang set khach_hang.capdo = 'D' where khach_hang.idkh = id_kh;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tinh_tien_hoa_don` (IN `ma_hoa_don` INT)  NO SQL
BEGIN
	declare tien_hoa_don int;
	set tien_hoa_don = `tinh_tien_hoa_don`(ma_hoa_don);
	UPDATE hoa_don set hoa_don.tongtien = tien_hoa_don where hoa_don.mahoadon = ma_hoa_don;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `doanh_thu_theo_thoi_gian` (`day1` DATE, `day2` DATE) RETURNS INT NO SQL
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE sum INT DEFAULT 0;
    declare money INT;
	DECLARE money_cursor CURSOR FOR select hd.tongtien from hoa_don as hd where hd.ngayxuat >= day1 and hd.ngayxuat <= day2;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN money_cursor;
	read_loop: LOOP
		FETCH money_cursor into money;
		IF done THEN
 		     LEAVE read_loop;
		END IF;
		set sum = sum + money;
	END LOOP;
	CLOSE money_cursor;
	return sum;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `tinh_tien_dich_vu` (`ma_hoa_don` INT) RETURNS INT NO SQL
BEGIN
	DECLARE done INT DEFAULT 0;
	declare dichvu, soluong INT;
    DECLARE sum INT DEFAULT 0;
	DECLARE money_cursor CURSOR FOR select dv.gia, sddv.soluong from su_dung_dich_vu as sddv, dich_vu as dv
		where sddv.mahoadon = ma_hoa_don AND
			sddv.madv = dv.madv;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN money_cursor;
	read_loop: LOOP
		FETCH money_cursor into dichvu, soluong;
		IF done THEN
 		     LEAVE read_loop;
		END IF;
		set sum = sum + dichvu*soluong;
	END LOOP;
	CLOSE money_cursor;
	return sum;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `tinh_tien_hoa_don` (`ma_hoa_don` INT) RETURNS INT NO SQL
BEGIN
	declare tien_hoa_don int;
	declare phantram float;
	set tien_hoa_don =  `tinh_tien_phim`(ma_hoa_don);
	set tien_hoa_don =  tien_hoa_don + `tinh_tien_dich_vu`(ma_hoa_don);

	set phantram = (select km.giamgia from hoa_don as hd, 	hoa_don_khuyen_mai as hdkm, khuyen_mai as km
		where hd.mahoadon = hdkm.mahoadon AND
    		hdkm.makm = km.makm AND
        	hd.mahoadon = ma_hoa_don);
    if (phantram <=> NULL) THEN
    	set phantram = 0;
    END IF;
	set tien_hoa_don = tien_hoa_don*(1-phantram);
	return tien_hoa_don;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `tinh_tien_khach_hang` (`id_kh` INT) RETURNS INT NO SQL
BEGIN
	DECLARE done INT DEFAULT 0;
	declare money INT;
    DECLARE sum INT DEFAULT 0;
	DECLARE money_cursor CURSOR FOR select hd.tongtien from hoa_don as hd WHERE hd.idkh = id_kh;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN money_cursor;
	read_loop: LOOP
		FETCH money_cursor into money;
		IF done THEN
 		     LEAVE read_loop;
		END IF;
		set sum = sum + money;
	END LOOP;
	CLOSE money_cursor;
	return sum;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `tinh_tien_phim` (`ma_hoa_don` INT) RETURNS INT NO SQL
BEGIN
	DECLARE done INT DEFAULT FALSE;
	declare giaphong, giaghe INT;
    DECLARE sum INT DEFAULT 0;
	DECLARE money_cursor CURSOR FOR select lp.gia as 'Gia phong', lg.gia as 'Gia ghe' from ve as v, ghe_ngoi as gn, loai_ghe as lg, phong_chieu as pc, loai_phong as lp
    where v.mahoadon = ma_hoa_don AND
        v.maghe = gn.maghe AND
        gn.tenloai = lg.tenloai AND
        gn.maphong = pc.maphong AND
        pc.tenloai = lp.tenloai;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN money_cursor;
	read_loop: LOOP
		FETCH money_cursor into giaphong, giaghe;
		IF done THEN
 		     LEAVE read_loop;
		END IF;
		set sum = sum + giaphong + giaghe;
	END LOOP;
	CLOSE money_cursor;
	return sum;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `dia_ban`
--

CREATE TABLE `dia_ban` (
  `maqh` int NOT NULL,
  `tenqh` varchar(100) DEFAULT NULL,
  `sorap` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `dia_ban`
--

INSERT INTO `dia_ban` (`maqh`, `tenqh`, `sorap`) VALUES
(1, 'Hà Đông', 1),
(2, 'Nam Từ Liêm', 1),
(3, 'Đống Đa', 1),
(4, 'Hai Bà Trưng', 1),
(5, 'Thanh Xuân', 1),
(6, 'Cầu Giấy', 1);

-- --------------------------------------------------------

--
-- Table structure for table `dich_vu`
--

CREATE TABLE `dich_vu` (
  `madv` int NOT NULL,
  `loaidv` varchar(50) DEFAULT NULL,
  `tendv` varchar(50) DEFAULT NULL,
  `gia` int DEFAULT NULL,
  `hinhanh` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `dich_vu`
--

INSERT INTO `dich_vu` (`madv`, `loaidv`, `tendv`, `gia`, `hinhanh`) VALUES
(1, 'Thức ăn', 'Bỏng ngô', 10000, 'sources/img/bong-ngo.jpg'),
(2, 'Thức ăn', 'Khoai tây chiên', 15000, 'sources/img/khoai-tay-chien.jpg'),
(3, 'Thức uống', 'Coca Cola', 10000, 'sources/img/cocacola.png'),
(4, 'Thức uống', 'Trà sữa', 20000, 'sources/img/tra-sua.jpg'),
(5, 'Thức uống', 'Sinh tố trái cây', 25000, 'sources/img/sinh-to-trai-cay.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `dien_vien`
--

CREATE TABLE `dien_vien` (
  `maphim` int NOT NULL,
  `dienvien` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `dien_vien`
--

INSERT INTO `dien_vien` (`maphim`, `dienvien`) VALUES
(1, 'Josh Brolin'),
(1, 'Julian Dennison'),
(1, 'Morena Baccarin'),
(1, 'Ryan Reynolds'),
(1, 'T. J. Miller'),
(1, 'Zazie Beetz'),
(2, 'Dave Bautista'),
(2, 'Karen Gillan'),
(2, 'Tom Holland'),
(3, 'Bryce Dallas Howard'),
(3, 'Chris Pratt'),
(3, 'Judy Greer'),
(3, 'Vincent D\'Onofrio'),
(4, 'hotgirl Nene'),
(4, 'Huy Khánh'),
(4, 'Kiều Minh Tuấn'),
(4, 'Song Luân'),
(5, 'Gin Tuấn Kiệt'),
(5, 'Jun Phạm'),
(5, 'Khả Ngân'),
(5, 'NSƯT Mỹ Uyên'),
(6, 'Alexandra Lamy'),
(6, 'Elsa Zylberstein'),
(6, 'Franck Dubosc'),
(7, 'Greg Proops'),
(7, 'Jim Gaffigan'),
(7, 'Lance Lim'),
(7, 'Zendaya'),
(8, 'Bruce Willis'),
(8, 'Elisabeth Shue'),
(8, 'Vincent D\'Onofrio'),
(9, 'Diệu Nhi'),
(9, 'Khả Như'),
(9, 'La Thành'),
(9, 'Thuận Nguyễn'),
(10, 'Dwayne Johnson'),
(10, 'Jeffrey Dean Morgan'),
(10, 'Malin Akerman'),
(11, 'George Bailey'),
(11, 'H.D. Quinn'),
(11, 'Marc Thompson'),
(11, 'Mike Pollock'),
(11, 'Sondra James'),
(12, 'Alden Ehrenreich'),
(12, 'Emilia Clarke'),
(12, 'Thandie Newton'),
(13, 'Kakazu Yumi'),
(13, 'Kimura Subaru'),
(13, 'Mizuta Wasabi'),
(13, 'Ohara Megumi'),
(14, 'Ngọc Trai'),
(14, 'Đại Nghĩa'),
(15, 'Dwayne Johnson'),
(15, 'Neve Campbell'),
(15, 'Pablo Schreiber'),
(16, 'Jason Statham'),
(16, 'Rainn Wilson'),
(16, 'Ruby Rose'),
(17, 'Evangeline Lilly'),
(17, 'Michelle Pfeiffer'),
(17, 'Walton Goggins'),
(18, 'Benedict Cumberbatch'),
(19, 'Holly Hunter'),
(19, 'Samuel L. Jackson'),
(19, 'Sarah Vowell '),
(20, 'Emily Blunt'),
(20, 'John Krasinski'),
(20, 'Noah Jupe');

-- --------------------------------------------------------

--
-- Table structure for table `ghe_ngoi`
--

CREATE TABLE `ghe_ngoi` (
  `maghe` int NOT NULL,
  `soghe` varchar(10) DEFAULT NULL,
  `maphong` int NOT NULL,
  `marap` int NOT NULL,
  `tenloai` varchar(10) NOT NULL,
  `tinhtrang` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ghe_ngoi`
--

INSERT INTO `ghe_ngoi` (`maghe`, `soghe`, `maphong`, `marap`, `tenloai`, `tinhtrang`) VALUES
(132, 'A1', 57, 1, 'Ghế Thường', 0),
(133, 'A2', 57, 1, 'Ghế Thường', 0),
(134, 'A3', 57, 1, 'Ghế Thường', 0),
(135, 'A4', 57, 1, 'Ghế Thường', 0),
(136, 'A5', 57, 1, 'Ghế Thường', 0),
(137, 'A6', 57, 1, 'Ghế Thường', 0),
(138, 'A7', 57, 1, 'Ghế Thường', 0),
(139, 'A8', 57, 1, 'Ghế Thường', 0),
(140, 'A9', 57, 1, 'Ghế Thường', 0),
(141, 'A10', 57, 1, 'Ghế Thường', 0),
(142, 'A11', 57, 1, 'Ghế Thường', 0),
(143, 'A12', 57, 1, 'Ghế Thường', 0),
(144, 'B1', 57, 1, 'Ghế Thường', 0),
(145, 'B2', 57, 1, 'Ghế Thường', 0),
(146, 'B3', 57, 1, 'Ghế Thường', 0),
(147, 'B4', 57, 1, 'Ghế Thường', 0),
(148, 'B5', 57, 1, 'Ghế Thường', 0),
(149, 'B6', 57, 1, 'Ghế Thường', 0),
(150, 'B7', 57, 1, 'Ghế Thường', 0),
(151, 'B8', 57, 1, 'Ghế Thường', 0),
(152, 'B9', 57, 1, 'Ghế Thường', 0),
(153, 'B10', 57, 1, 'Ghế Thường', 0),
(154, 'B11', 57, 1, 'Ghế Thường', 0),
(155, 'B12', 57, 1, 'Ghế Thường', 0),
(156, 'C1', 57, 1, 'Ghế Thường', 0),
(157, 'C2', 57, 1, 'Ghế Thường', 0),
(158, 'C3', 57, 1, 'Ghế Thường', 0),
(159, 'C4', 57, 1, 'Ghế Thường', 0),
(160, 'C5', 57, 1, 'Ghế Thường', 0),
(161, 'C6', 57, 1, 'Ghế Thường', 0),
(162, 'C7', 57, 1, 'Ghế Thường', 0),
(163, 'C8', 57, 1, 'Ghế Thường', 0),
(164, 'C9', 57, 1, 'Ghế Thường', 0),
(165, 'C10', 57, 1, 'Ghế Thường', 0),
(166, 'C11', 57, 1, 'Ghế Thường', 0),
(167, 'C12', 57, 1, 'Ghế Thường', 0),
(168, 'D1', 57, 1, 'Ghế Thường', 0),
(169, 'D2', 57, 1, 'Ghế Thường', 0),
(170, 'D3', 57, 1, 'Ghế Thường', 0),
(171, 'D4', 57, 1, 'Ghế Thường', 0),
(172, 'D5', 57, 1, 'Ghế Thường', 0),
(173, 'D6', 57, 1, 'Ghế Thường', 0),
(174, 'D7', 57, 1, 'Ghế Thường', 0),
(175, 'D8', 57, 1, 'Ghế Thường', 0),
(176, 'D9', 57, 1, 'Ghế Thường', 0),
(177, 'D10', 57, 1, 'Ghế Thường', 0),
(178, 'D11', 57, 1, 'Ghế Thường', 0),
(179, 'D12', 57, 1, 'Ghế Thường', 0),
(180, 'E1', 57, 1, 'Ghế Thường', 0),
(181, 'E2', 57, 1, 'Ghế Thường', 0),
(182, 'E3', 57, 1, 'Ghế Thường', 0),
(183, 'E4', 57, 1, 'Ghế Thường', 0),
(184, 'E5', 57, 1, 'Ghế Thường', 0),
(185, 'E6', 57, 1, 'Ghế Thường', 0),
(186, 'E7', 57, 1, 'Ghế Thường', 0),
(187, 'E8', 57, 1, 'Ghế Thường', 0),
(188, 'E9', 57, 1, 'Ghế Thường', 0),
(189, 'E10', 57, 1, 'Ghế Thường', 0),
(190, 'E11', 57, 1, 'Ghế Thường', 0),
(191, 'E12', 57, 1, 'Ghế Thường', 0),
(192, 'F1', 57, 1, 'Ghế Thường', 0),
(193, 'F2', 57, 1, 'Ghế Thường', 0),
(194, 'F3', 57, 1, 'Ghế Thường', 0),
(195, 'F4', 57, 1, 'Ghế Thường', 0),
(196, 'F5', 57, 1, 'Ghế Thường', 0),
(197, 'F6', 57, 1, 'Ghế Thường', 0),
(198, 'F7', 57, 1, 'Ghế Thường', 0),
(199, 'F8', 57, 1, 'Ghế Thường', 0),
(200, 'F9', 57, 1, 'Ghế Thường', 0),
(201, 'F10', 57, 1, 'Ghế Thường', 0),
(202, 'F11', 57, 1, 'Ghế Thường', 0),
(203, 'F12', 57, 1, 'Ghế Thường', 0),
(204, 'G1', 57, 1, 'Ghế Thường', 0),
(205, 'G2', 57, 1, 'Ghế Thường', 0),
(206, 'G3', 57, 1, 'Ghế Thường', 0),
(207, 'G4', 57, 1, 'Ghế Thường', 0),
(208, 'G5', 57, 1, 'Ghế Thường', 0),
(209, 'G6', 57, 1, 'Ghế Thường', 0),
(210, 'G7', 57, 1, 'Ghế Thường', 0),
(211, 'G8', 57, 1, 'Ghế Thường', 1),
(212, 'G9', 57, 1, 'Ghế Thường', 0),
(213, 'G10', 57, 1, 'Ghế Thường', 0),
(214, 'G11', 57, 1, 'Ghế Thường', 0),
(215, 'G12', 57, 1, 'Ghế Thường', 0),
(216, 'H1', 57, 1, 'Ghế Thường', 0),
(217, 'H2', 57, 1, 'Ghế Thường', 0),
(218, 'H3', 57, 1, 'Ghế Thường', 0),
(219, 'H4', 57, 1, 'Ghế Thường', 0),
(220, 'H5', 57, 1, 'Ghế Thường', 0),
(221, 'H6', 57, 1, 'Ghế Thường', 0),
(222, 'H7', 57, 1, 'Ghế Thường', 0),
(223, 'H8', 57, 1, 'Ghế Thường', 0),
(224, 'H9', 57, 1, 'Ghế Thường', 0),
(225, 'H10', 57, 1, 'Ghế Thường', 0),
(226, 'H11', 57, 1, 'Ghế Thường', 0),
(227, 'H12', 57, 1, 'Ghế Thường', 0),
(228, 'I1', 57, 1, 'Ghế Thường', 0),
(229, 'I2', 57, 1, 'Ghế Thường', 0),
(230, 'I3', 57, 1, 'Ghế Thường', 0),
(231, 'I4', 57, 1, 'Ghế Thường', 0),
(232, 'I5', 57, 1, 'Ghế Thường', 0),
(233, 'I6', 57, 1, 'Ghế Thường', 0),
(234, 'I7', 57, 1, 'Ghế Thường', 0),
(235, 'I8', 57, 1, 'Ghế Thường', 0),
(236, 'I9', 57, 1, 'Ghế Thường', 0),
(237, 'I10', 57, 1, 'Ghế Thường', 0),
(238, 'I11', 57, 1, 'Ghế Thường', 0),
(239, 'I12', 57, 1, 'Ghế Thường', 0),
(240, 'J1', 57, 1, 'Ghế đôi', 0),
(241, 'J2', 57, 1, 'Ghế đôi', 0),
(242, 'J3', 57, 1, 'Ghế đôi', 0),
(243, 'J4', 57, 1, 'Ghế đôi', 0),
(244, 'J5', 57, 1, 'Ghế đôi', 0),
(245, 'J6', 57, 1, 'Ghế đôi', 0),
(246, 'J7', 57, 1, 'Ghế đôi', 0),
(247, 'J8', 57, 1, 'Ghế đôi', 0),
(248, 'J9', 57, 1, 'Ghế đôi', 0),
(249, 'J10', 57, 1, 'Ghế đôi', 0),
(250, 'J11', 57, 1, 'Ghế đôi', 0),
(251, 'J12', 57, 1, 'Ghế đôi', 0),
(252, 'A1', 58, 1, 'Ghế Thường', 0),
(253, 'A2', 58, 1, 'Ghế Thường', 0),
(254, 'A3', 58, 1, 'Ghế Thường', 0),
(255, 'A4', 58, 1, 'Ghế Thường', 0),
(256, 'A5', 58, 1, 'Ghế Thường', 0),
(257, 'A6', 58, 1, 'Ghế Thường', 0),
(258, 'A7', 58, 1, 'Ghế Thường', 0),
(259, 'A8', 58, 1, 'Ghế Thường', 0),
(260, 'A9', 58, 1, 'Ghế Thường', 0),
(261, 'A10', 58, 1, 'Ghế Thường', 0),
(262, 'A11', 58, 1, 'Ghế Thường', 0),
(263, 'A12', 58, 1, 'Ghế Thường', 0),
(264, 'B1', 58, 1, 'Ghế Thường', 0),
(265, 'B2', 58, 1, 'Ghế Thường', 0),
(266, 'B3', 58, 1, 'Ghế Thường', 0),
(267, 'B4', 58, 1, 'Ghế Thường', 0),
(268, 'B5', 58, 1, 'Ghế Thường', 0),
(269, 'B6', 58, 1, 'Ghế Thường', 0),
(270, 'B7', 58, 1, 'Ghế Thường', 0),
(271, 'B8', 58, 1, 'Ghế Thường', 0),
(272, 'B9', 58, 1, 'Ghế Thường', 0),
(273, 'B10', 58, 1, 'Ghế Thường', 0),
(274, 'B11', 58, 1, 'Ghế Thường', 0),
(275, 'B12', 58, 1, 'Ghế Thường', 0),
(276, 'C1', 58, 1, 'Ghế Thường', 0),
(277, 'C2', 58, 1, 'Ghế Thường', 0),
(278, 'C3', 58, 1, 'Ghế Thường', 0),
(279, 'C4', 58, 1, 'Ghế Thường', 0),
(280, 'C5', 58, 1, 'Ghế Thường', 0),
(281, 'C6', 58, 1, 'Ghế Thường', 0),
(282, 'C7', 58, 1, 'Ghế Thường', 0),
(283, 'C8', 58, 1, 'Ghế Thường', 0),
(284, 'C9', 58, 1, 'Ghế Thường', 0),
(285, 'C10', 58, 1, 'Ghế Thường', 0),
(286, 'C11', 58, 1, 'Ghế Thường', 0),
(287, 'C12', 58, 1, 'Ghế Thường', 0),
(288, 'D1', 58, 1, 'Ghế Thường', 0),
(289, 'D2', 58, 1, 'Ghế Thường', 0),
(290, 'D3', 58, 1, 'Ghế Thường', 0),
(291, 'D4', 58, 1, 'Ghế Thường', 0),
(292, 'D5', 58, 1, 'Ghế Thường', 0),
(293, 'D6', 58, 1, 'Ghế Thường', 0),
(294, 'D7', 58, 1, 'Ghế Thường', 1),
(295, 'D8', 58, 1, 'Ghế Thường', 0),
(296, 'D9', 58, 1, 'Ghế Thường', 0),
(297, 'D10', 58, 1, 'Ghế Thường', 0),
(298, 'D11', 58, 1, 'Ghế Thường', 0),
(299, 'D12', 58, 1, 'Ghế Thường', 0),
(300, 'E1', 58, 1, 'Ghế Thường', 0),
(301, 'E2', 58, 1, 'Ghế Thường', 0),
(302, 'E3', 58, 1, 'Ghế Thường', 0),
(303, 'E4', 58, 1, 'Ghế Thường', 0),
(304, 'E5', 58, 1, 'Ghế Thường', 0),
(305, 'E6', 58, 1, 'Ghế Thường', 0),
(306, 'E7', 58, 1, 'Ghế Thường', 0),
(307, 'E8', 58, 1, 'Ghế Thường', 0),
(308, 'E9', 58, 1, 'Ghế Thường', 0),
(309, 'E10', 58, 1, 'Ghế Thường', 0),
(310, 'E11', 58, 1, 'Ghế Thường', 0),
(311, 'E12', 58, 1, 'Ghế Thường', 0),
(312, 'F1', 58, 1, 'Ghế Thường', 0),
(313, 'F2', 58, 1, 'Ghế Thường', 0),
(314, 'F3', 58, 1, 'Ghế Thường', 0),
(315, 'F4', 58, 1, 'Ghế Thường', 0),
(316, 'F5', 58, 1, 'Ghế Thường', 0),
(317, 'F6', 58, 1, 'Ghế Thường', 1),
(318, 'F7', 58, 1, 'Ghế Thường', 0),
(319, 'F8', 58, 1, 'Ghế Thường', 1),
(320, 'F9', 58, 1, 'Ghế Thường', 0),
(321, 'F10', 58, 1, 'Ghế Thường', 0),
(322, 'F11', 58, 1, 'Ghế Thường', 0),
(323, 'F12', 58, 1, 'Ghế Thường', 0),
(324, 'G1', 58, 1, 'Ghế Thường', 0),
(325, 'G2', 58, 1, 'Ghế Thường', 0),
(326, 'G3', 58, 1, 'Ghế Thường', 0),
(327, 'G4', 58, 1, 'Ghế Thường', 0),
(328, 'G5', 58, 1, 'Ghế Thường', 0),
(329, 'G6', 58, 1, 'Ghế Thường', 0),
(330, 'G7', 58, 1, 'Ghế Thường', 0),
(331, 'G8', 58, 1, 'Ghế Thường', 0),
(332, 'G9', 58, 1, 'Ghế Thường', 0),
(333, 'G10', 58, 1, 'Ghế Thường', 0),
(334, 'G11', 58, 1, 'Ghế Thường', 0),
(335, 'G12', 58, 1, 'Ghế Thường', 0),
(336, 'H1', 58, 1, 'Ghế Thường', 0),
(337, 'H2', 58, 1, 'Ghế Thường', 0),
(338, 'H3', 58, 1, 'Ghế Thường', 0),
(339, 'H4', 58, 1, 'Ghế Thường', 0),
(340, 'H5', 58, 1, 'Ghế Thường', 0),
(341, 'H6', 58, 1, 'Ghế Thường', 0),
(342, 'H7', 58, 1, 'Ghế Thường', 0),
(343, 'H8', 58, 1, 'Ghế Thường', 0),
(344, 'H9', 58, 1, 'Ghế Thường', 0),
(345, 'H10', 58, 1, 'Ghế Thường', 0),
(346, 'H11', 58, 1, 'Ghế Thường', 0),
(347, 'H12', 58, 1, 'Ghế Thường', 0),
(348, 'I1', 58, 1, 'Ghế Thường', 0),
(349, 'I2', 58, 1, 'Ghế Thường', 0),
(350, 'I3', 58, 1, 'Ghế Thường', 0),
(351, 'I4', 58, 1, 'Ghế Thường', 0),
(352, 'I5', 58, 1, 'Ghế Thường', 0),
(353, 'I6', 58, 1, 'Ghế Thường', 0),
(354, 'I7', 58, 1, 'Ghế Thường', 0),
(355, 'I8', 58, 1, 'Ghế Thường', 0),
(356, 'I9', 58, 1, 'Ghế Thường', 0),
(357, 'I10', 58, 1, 'Ghế Thường', 0),
(358, 'I11', 58, 1, 'Ghế Thường', 0),
(359, 'I12', 58, 1, 'Ghế Thường', 0),
(360, 'J1', 58, 1, 'Ghế đôi', 0),
(361, 'J2', 58, 1, 'Ghế đôi', 0),
(362, 'J3', 58, 1, 'Ghế đôi', 0),
(363, 'J4', 58, 1, 'Ghế đôi', 0),
(364, 'J5', 58, 1, 'Ghế đôi', 0),
(365, 'J6', 58, 1, 'Ghế đôi', 0),
(366, 'J7', 58, 1, 'Ghế đôi', 1),
(367, 'J8', 58, 1, 'Ghế đôi', 0),
(368, 'J9', 58, 1, 'Ghế đôi', 0),
(369, 'J10', 58, 1, 'Ghế đôi', 0),
(370, 'J11', 58, 1, 'Ghế đôi', 0),
(371, 'J12', 58, 1, 'Ghế đôi', 0),
(372, 'A1', 59, 1, 'Ghế Imax', 0),
(373, 'A2', 59, 1, 'Ghế Imax', 0),
(374, 'A3', 59, 1, 'Ghế Imax', 0),
(375, 'A4', 59, 1, 'Ghế Imax', 0),
(376, 'A5', 59, 1, 'Ghế Imax', 0),
(377, 'A6', 59, 1, 'Ghế Imax', 0),
(378, 'A7', 59, 1, 'Ghế Imax', 0),
(379, 'A8', 59, 1, 'Ghế Imax', 0),
(380, 'A9', 59, 1, 'Ghế Imax', 0),
(381, 'A10', 59, 1, 'Ghế Imax', 0),
(382, 'A11', 59, 1, 'Ghế Imax', 0),
(383, 'A12', 59, 1, 'Ghế Imax', 0),
(384, 'B1', 59, 1, 'Ghế Imax', 0),
(385, 'B2', 59, 1, 'Ghế Imax', 0),
(386, 'B3', 59, 1, 'Ghế Imax', 0),
(387, 'B4', 59, 1, 'Ghế Imax', 0),
(388, 'B5', 59, 1, 'Ghế Imax', 0),
(389, 'B6', 59, 1, 'Ghế Imax', 0),
(390, 'B7', 59, 1, 'Ghế Imax', 0),
(391, 'B8', 59, 1, 'Ghế Imax', 0),
(392, 'B9', 59, 1, 'Ghế Imax', 0),
(393, 'B10', 59, 1, 'Ghế Imax', 0),
(394, 'B11', 59, 1, 'Ghế Imax', 0),
(395, 'B12', 59, 1, 'Ghế Imax', 0),
(396, 'C1', 59, 1, 'Ghế Imax', 0),
(397, 'C2', 59, 1, 'Ghế Imax', 0),
(398, 'C3', 59, 1, 'Ghế Imax', 0),
(399, 'C4', 59, 1, 'Ghế Imax', 0),
(400, 'C5', 59, 1, 'Ghế Imax', 0),
(401, 'C6', 59, 1, 'Ghế Imax', 0),
(402, 'C7', 59, 1, 'Ghế Imax', 0),
(403, 'C8', 59, 1, 'Ghế Imax', 0),
(404, 'C9', 59, 1, 'Ghế Imax', 0),
(405, 'C10', 59, 1, 'Ghế Imax', 0),
(406, 'C11', 59, 1, 'Ghế Imax', 0),
(407, 'C12', 59, 1, 'Ghế Imax', 0),
(408, 'D1', 59, 1, 'Ghế Imax', 0),
(409, 'D2', 59, 1, 'Ghế Imax', 0),
(410, 'D3', 59, 1, 'Ghế Imax', 0),
(411, 'D4', 59, 1, 'Ghế Imax', 0),
(412, 'D5', 59, 1, 'Ghế Imax', 0),
(413, 'D6', 59, 1, 'Ghế Imax', 0),
(414, 'D7', 59, 1, 'Ghế Imax', 0),
(415, 'D8', 59, 1, 'Ghế Imax', 0),
(416, 'D9', 59, 1, 'Ghế Imax', 0),
(417, 'D10', 59, 1, 'Ghế Imax', 0),
(418, 'D11', 59, 1, 'Ghế Imax', 0),
(419, 'D12', 59, 1, 'Ghế Imax', 0),
(420, 'E1', 59, 1, 'Ghế Imax', 0),
(421, 'E2', 59, 1, 'Ghế Imax', 0),
(422, 'E3', 59, 1, 'Ghế Imax', 0),
(423, 'E4', 59, 1, 'Ghế Imax', 0),
(424, 'E5', 59, 1, 'Ghế Imax', 0),
(425, 'E6', 59, 1, 'Ghế Imax', 0),
(426, 'E7', 59, 1, 'Ghế Imax', 0),
(427, 'E8', 59, 1, 'Ghế Imax', 0),
(428, 'E9', 59, 1, 'Ghế Imax', 0),
(429, 'E10', 59, 1, 'Ghế Imax', 0),
(430, 'E11', 59, 1, 'Ghế Imax', 0),
(431, 'E12', 59, 1, 'Ghế Imax', 0),
(432, 'F1', 59, 1, 'Ghế Imax', 0),
(433, 'F2', 59, 1, 'Ghế Imax', 0),
(434, 'F3', 59, 1, 'Ghế Imax', 0),
(435, 'F4', 59, 1, 'Ghế Imax', 0),
(436, 'F5', 59, 1, 'Ghế Imax', 0),
(437, 'F6', 59, 1, 'Ghế Imax', 0),
(438, 'F7', 59, 1, 'Ghế Imax', 0),
(439, 'F8', 59, 1, 'Ghế Imax', 0),
(440, 'F9', 59, 1, 'Ghế Imax', 0),
(441, 'F10', 59, 1, 'Ghế Imax', 0),
(442, 'F11', 59, 1, 'Ghế Imax', 0),
(443, 'F12', 59, 1, 'Ghế Imax', 0),
(444, 'G1', 59, 1, 'Ghế Imax', 0),
(445, 'G2', 59, 1, 'Ghế Imax', 0),
(446, 'G3', 59, 1, 'Ghế Imax', 0),
(447, 'G4', 59, 1, 'Ghế Imax', 0),
(448, 'G5', 59, 1, 'Ghế Imax', 0),
(449, 'G6', 59, 1, 'Ghế Imax', 0),
(450, 'G7', 59, 1, 'Ghế Imax', 0),
(451, 'G8', 59, 1, 'Ghế Imax', 0),
(452, 'G9', 59, 1, 'Ghế Imax', 0),
(453, 'G10', 59, 1, 'Ghế Imax', 0),
(454, 'G11', 59, 1, 'Ghế Imax', 0),
(455, 'G12', 59, 1, 'Ghế Imax', 0),
(456, 'H1', 59, 1, 'Ghế Imax', 0),
(457, 'H2', 59, 1, 'Ghế Imax', 0),
(458, 'H3', 59, 1, 'Ghế Imax', 0),
(459, 'H4', 59, 1, 'Ghế Imax', 0),
(460, 'H5', 59, 1, 'Ghế Imax', 0),
(461, 'H6', 59, 1, 'Ghế Imax', 0),
(462, 'H7', 59, 1, 'Ghế Imax', 0),
(463, 'H8', 59, 1, 'Ghế Imax', 0),
(464, 'H9', 59, 1, 'Ghế Imax', 0),
(465, 'H10', 59, 1, 'Ghế Imax', 0),
(466, 'H11', 59, 1, 'Ghế Imax', 0),
(467, 'H12', 59, 1, 'Ghế Imax', 0),
(468, 'I1', 59, 1, 'Ghế Imax', 0),
(469, 'I2', 59, 1, 'Ghế Imax', 0),
(470, 'I3', 59, 1, 'Ghế Imax', 0),
(471, 'I4', 59, 1, 'Ghế Imax', 0),
(472, 'I5', 59, 1, 'Ghế Imax', 0),
(473, 'I6', 59, 1, 'Ghế Imax', 0),
(474, 'I7', 59, 1, 'Ghế Imax', 0),
(475, 'I8', 59, 1, 'Ghế Imax', 0),
(476, 'I9', 59, 1, 'Ghế Imax', 0),
(477, 'I10', 59, 1, 'Ghế Imax', 0),
(478, 'I11', 59, 1, 'Ghế Imax', 0),
(479, 'I12', 59, 1, 'Ghế Imax', 0),
(480, 'J1', 59, 1, 'Ghế Imax', 0),
(481, 'J2', 59, 1, 'Ghế Imax', 0),
(482, 'J3', 59, 1, 'Ghế Imax', 0),
(483, 'J4', 59, 1, 'Ghế Imax', 0),
(484, 'J5', 59, 1, 'Ghế Imax', 0),
(485, 'J6', 59, 1, 'Ghế Imax', 0),
(486, 'J7', 59, 1, 'Ghế Imax', 0),
(487, 'J8', 59, 1, 'Ghế Imax', 0),
(488, 'J9', 59, 1, 'Ghế Imax', 0),
(489, 'J10', 59, 1, 'Ghế Imax', 0),
(490, 'J11', 59, 1, 'Ghế Imax', 0),
(491, 'J12', 59, 1, 'Ghế Imax', 0),
(492, 'A1', 60, 2, 'Ghế Thường', 0),
(493, 'A2', 60, 2, 'Ghế Thường', 0),
(494, 'A3', 60, 2, 'Ghế Thường', 0),
(495, 'A4', 60, 2, 'Ghế Thường', 0),
(496, 'A5', 60, 2, 'Ghế Thường', 0),
(497, 'A6', 60, 2, 'Ghế Thường', 0),
(498, 'A7', 60, 2, 'Ghế Thường', 0),
(499, 'A8', 60, 2, 'Ghế Thường', 0),
(500, 'A9', 60, 2, 'Ghế Thường', 0),
(501, 'A10', 60, 2, 'Ghế Thường', 0),
(502, 'A11', 60, 2, 'Ghế Thường', 0),
(503, 'A12', 60, 2, 'Ghế Thường', 0),
(504, 'B1', 60, 2, 'Ghế Thường', 0),
(505, 'B2', 60, 2, 'Ghế Thường', 0),
(506, 'B3', 60, 2, 'Ghế Thường', 0),
(507, 'B4', 60, 2, 'Ghế Thường', 0),
(508, 'B5', 60, 2, 'Ghế Thường', 0),
(509, 'B6', 60, 2, 'Ghế Thường', 0),
(510, 'B7', 60, 2, 'Ghế Thường', 0),
(511, 'B8', 60, 2, 'Ghế Thường', 0),
(512, 'B9', 60, 2, 'Ghế Thường', 0),
(513, 'B10', 60, 2, 'Ghế Thường', 0),
(514, 'B11', 60, 2, 'Ghế Thường', 0),
(515, 'B12', 60, 2, 'Ghế Thường', 0),
(516, 'C1', 60, 2, 'Ghế Thường', 0),
(517, 'C2', 60, 2, 'Ghế Thường', 0),
(518, 'C3', 60, 2, 'Ghế Thường', 0),
(519, 'C4', 60, 2, 'Ghế Thường', 0),
(520, 'C5', 60, 2, 'Ghế Thường', 0),
(521, 'C6', 60, 2, 'Ghế Thường', 0),
(522, 'C7', 60, 2, 'Ghế Thường', 0),
(523, 'C8', 60, 2, 'Ghế Thường', 0),
(524, 'C9', 60, 2, 'Ghế Thường', 0),
(525, 'C10', 60, 2, 'Ghế Thường', 0),
(526, 'C11', 60, 2, 'Ghế Thường', 0),
(527, 'C12', 60, 2, 'Ghế Thường', 0),
(528, 'D1', 60, 2, 'Ghế Thường', 0),
(529, 'D2', 60, 2, 'Ghế Thường', 0),
(530, 'D3', 60, 2, 'Ghế Thường', 0),
(531, 'D4', 60, 2, 'Ghế Thường', 0),
(532, 'D5', 60, 2, 'Ghế Thường', 0),
(533, 'D6', 60, 2, 'Ghế Thường', 0),
(534, 'D7', 60, 2, 'Ghế Thường', 0),
(535, 'D8', 60, 2, 'Ghế Thường', 0),
(536, 'D9', 60, 2, 'Ghế Thường', 0),
(537, 'D10', 60, 2, 'Ghế Thường', 0),
(538, 'D11', 60, 2, 'Ghế Thường', 0),
(539, 'D12', 60, 2, 'Ghế Thường', 0),
(540, 'E1', 60, 2, 'Ghế Thường', 0),
(541, 'E2', 60, 2, 'Ghế Thường', 0),
(542, 'E3', 60, 2, 'Ghế Thường', 0),
(543, 'E4', 60, 2, 'Ghế Thường', 0),
(544, 'E5', 60, 2, 'Ghế Thường', 0),
(545, 'E6', 60, 2, 'Ghế Thường', 0),
(546, 'E7', 60, 2, 'Ghế Thường', 0),
(547, 'E8', 60, 2, 'Ghế Thường', 0),
(548, 'E9', 60, 2, 'Ghế Thường', 0),
(549, 'E10', 60, 2, 'Ghế Thường', 0),
(550, 'E11', 60, 2, 'Ghế Thường', 0),
(551, 'E12', 60, 2, 'Ghế Thường', 0),
(552, 'F1', 60, 2, 'Ghế Thường', 0),
(553, 'F2', 60, 2, 'Ghế Thường', 0),
(554, 'F3', 60, 2, 'Ghế Thường', 0),
(555, 'F4', 60, 2, 'Ghế Thường', 0),
(556, 'F5', 60, 2, 'Ghế Thường', 0),
(557, 'F6', 60, 2, 'Ghế Thường', 0),
(558, 'F7', 60, 2, 'Ghế Thường', 0),
(559, 'F8', 60, 2, 'Ghế Thường', 0),
(560, 'F9', 60, 2, 'Ghế Thường', 0),
(561, 'F10', 60, 2, 'Ghế Thường', 0),
(562, 'F11', 60, 2, 'Ghế Thường', 0),
(563, 'F12', 60, 2, 'Ghế Thường', 0),
(564, 'G1', 60, 2, 'Ghế Thường', 0),
(565, 'G2', 60, 2, 'Ghế Thường', 0),
(566, 'G3', 60, 2, 'Ghế Thường', 0),
(567, 'G4', 60, 2, 'Ghế Thường', 0),
(568, 'G5', 60, 2, 'Ghế Thường', 0),
(569, 'G6', 60, 2, 'Ghế Thường', 0),
(570, 'G7', 60, 2, 'Ghế Thường', 0),
(571, 'G8', 60, 2, 'Ghế Thường', 0),
(572, 'G9', 60, 2, 'Ghế Thường', 0),
(573, 'G10', 60, 2, 'Ghế Thường', 0),
(574, 'G11', 60, 2, 'Ghế Thường', 0),
(575, 'G12', 60, 2, 'Ghế Thường', 0),
(576, 'H1', 60, 2, 'Ghế Thường', 0),
(577, 'H2', 60, 2, 'Ghế Thường', 0),
(578, 'H3', 60, 2, 'Ghế Thường', 0),
(579, 'H4', 60, 2, 'Ghế Thường', 0),
(580, 'H5', 60, 2, 'Ghế Thường', 0),
(581, 'H6', 60, 2, 'Ghế Thường', 0),
(582, 'H7', 60, 2, 'Ghế Thường', 0),
(583, 'H8', 60, 2, 'Ghế Thường', 0),
(584, 'H9', 60, 2, 'Ghế Thường', 0),
(585, 'H10', 60, 2, 'Ghế Thường', 0),
(586, 'H11', 60, 2, 'Ghế Thường', 0),
(587, 'H12', 60, 2, 'Ghế Thường', 0),
(588, 'I1', 60, 2, 'Ghế Thường', 0),
(589, 'I2', 60, 2, 'Ghế Thường', 0),
(590, 'I3', 60, 2, 'Ghế Thường', 0),
(591, 'I4', 60, 2, 'Ghế Thường', 0),
(592, 'I5', 60, 2, 'Ghế Thường', 0),
(593, 'I6', 60, 2, 'Ghế Thường', 0),
(594, 'I7', 60, 2, 'Ghế Thường', 0),
(595, 'I8', 60, 2, 'Ghế Thường', 0),
(596, 'I9', 60, 2, 'Ghế Thường', 0),
(597, 'I10', 60, 2, 'Ghế Thường', 0),
(598, 'I11', 60, 2, 'Ghế Thường', 0),
(599, 'I12', 60, 2, 'Ghế Thường', 0),
(600, 'J1', 60, 2, 'Ghế đôi', 0),
(601, 'J2', 60, 2, 'Ghế đôi', 0),
(602, 'J3', 60, 2, 'Ghế đôi', 0),
(603, 'J4', 60, 2, 'Ghế đôi', 0),
(604, 'J5', 60, 2, 'Ghế đôi', 0),
(605, 'J6', 60, 2, 'Ghế đôi', 0),
(606, 'J7', 60, 2, 'Ghế đôi', 0),
(607, 'J8', 60, 2, 'Ghế đôi', 0),
(608, 'J9', 60, 2, 'Ghế đôi', 0),
(609, 'J10', 60, 2, 'Ghế đôi', 0),
(610, 'J11', 60, 2, 'Ghế đôi', 0),
(611, 'J12', 60, 2, 'Ghế đôi', 0),
(612, 'A1', 61, 2, 'Ghế Imax', 0),
(613, 'A2', 61, 2, 'Ghế Imax', 0),
(614, 'A3', 61, 2, 'Ghế Imax', 0),
(615, 'A4', 61, 2, 'Ghế Imax', 0),
(616, 'A5', 61, 2, 'Ghế Imax', 0),
(617, 'A6', 61, 2, 'Ghế Imax', 0),
(618, 'A7', 61, 2, 'Ghế Imax', 0),
(619, 'A8', 61, 2, 'Ghế Imax', 0),
(620, 'A9', 61, 2, 'Ghế Imax', 0),
(621, 'A10', 61, 2, 'Ghế Imax', 0),
(622, 'A11', 61, 2, 'Ghế Imax', 0),
(623, 'A12', 61, 2, 'Ghế Imax', 0),
(624, 'B1', 61, 2, 'Ghế Imax', 0),
(625, 'B2', 61, 2, 'Ghế Imax', 0),
(626, 'B3', 61, 2, 'Ghế Imax', 0),
(627, 'B4', 61, 2, 'Ghế Imax', 0),
(628, 'B5', 61, 2, 'Ghế Imax', 0),
(629, 'B6', 61, 2, 'Ghế Imax', 0),
(630, 'B7', 61, 2, 'Ghế Imax', 0),
(631, 'B8', 61, 2, 'Ghế Imax', 0),
(632, 'B9', 61, 2, 'Ghế Imax', 0),
(633, 'B10', 61, 2, 'Ghế Imax', 0),
(634, 'B11', 61, 2, 'Ghế Imax', 0),
(635, 'B12', 61, 2, 'Ghế Imax', 0),
(636, 'C1', 61, 2, 'Ghế Imax', 0),
(637, 'C2', 61, 2, 'Ghế Imax', 0),
(638, 'C3', 61, 2, 'Ghế Imax', 0),
(639, 'C4', 61, 2, 'Ghế Imax', 0),
(640, 'C5', 61, 2, 'Ghế Imax', 0),
(641, 'C6', 61, 2, 'Ghế Imax', 0),
(642, 'C7', 61, 2, 'Ghế Imax', 0),
(643, 'C8', 61, 2, 'Ghế Imax', 0),
(644, 'C9', 61, 2, 'Ghế Imax', 0),
(645, 'C10', 61, 2, 'Ghế Imax', 0),
(646, 'C11', 61, 2, 'Ghế Imax', 0),
(647, 'C12', 61, 2, 'Ghế Imax', 0),
(648, 'D1', 61, 2, 'Ghế Imax', 0),
(649, 'D2', 61, 2, 'Ghế Imax', 0),
(650, 'D3', 61, 2, 'Ghế Imax', 0),
(651, 'D4', 61, 2, 'Ghế Imax', 0),
(652, 'D5', 61, 2, 'Ghế Imax', 0),
(653, 'D6', 61, 2, 'Ghế Imax', 0),
(654, 'D7', 61, 2, 'Ghế Imax', 0),
(655, 'D8', 61, 2, 'Ghế Imax', 0),
(656, 'D9', 61, 2, 'Ghế Imax', 0),
(657, 'D10', 61, 2, 'Ghế Imax', 0),
(658, 'D11', 61, 2, 'Ghế Imax', 0),
(659, 'D12', 61, 2, 'Ghế Imax', 0),
(660, 'E1', 61, 2, 'Ghế Imax', 0),
(661, 'E2', 61, 2, 'Ghế Imax', 0),
(662, 'E3', 61, 2, 'Ghế Imax', 0),
(663, 'E4', 61, 2, 'Ghế Imax', 0),
(664, 'E5', 61, 2, 'Ghế Imax', 0),
(665, 'E6', 61, 2, 'Ghế Imax', 0),
(666, 'E7', 61, 2, 'Ghế Imax', 0),
(667, 'E8', 61, 2, 'Ghế Imax', 0),
(668, 'E9', 61, 2, 'Ghế Imax', 0),
(669, 'E10', 61, 2, 'Ghế Imax', 0),
(670, 'E11', 61, 2, 'Ghế Imax', 0),
(671, 'E12', 61, 2, 'Ghế Imax', 0),
(672, 'F1', 61, 2, 'Ghế Imax', 0),
(673, 'F2', 61, 2, 'Ghế Imax', 0),
(674, 'F3', 61, 2, 'Ghế Imax', 0),
(675, 'F4', 61, 2, 'Ghế Imax', 0),
(676, 'F5', 61, 2, 'Ghế Imax', 0),
(677, 'F6', 61, 2, 'Ghế Imax', 0),
(678, 'F7', 61, 2, 'Ghế Imax', 0),
(679, 'F8', 61, 2, 'Ghế Imax', 0),
(680, 'F9', 61, 2, 'Ghế Imax', 0),
(681, 'F10', 61, 2, 'Ghế Imax', 0),
(682, 'F11', 61, 2, 'Ghế Imax', 0),
(683, 'F12', 61, 2, 'Ghế Imax', 0),
(684, 'G1', 61, 2, 'Ghế Imax', 0),
(685, 'G2', 61, 2, 'Ghế Imax', 0),
(686, 'G3', 61, 2, 'Ghế Imax', 0),
(687, 'G4', 61, 2, 'Ghế Imax', 0),
(688, 'G5', 61, 2, 'Ghế Imax', 0),
(689, 'G6', 61, 2, 'Ghế Imax', 0),
(690, 'G7', 61, 2, 'Ghế Imax', 0),
(691, 'G8', 61, 2, 'Ghế Imax', 0),
(692, 'G9', 61, 2, 'Ghế Imax', 0),
(693, 'G10', 61, 2, 'Ghế Imax', 0),
(694, 'G11', 61, 2, 'Ghế Imax', 0),
(695, 'G12', 61, 2, 'Ghế Imax', 0),
(696, 'H1', 61, 2, 'Ghế Imax', 0),
(697, 'H2', 61, 2, 'Ghế Imax', 0),
(698, 'H3', 61, 2, 'Ghế Imax', 0),
(699, 'H4', 61, 2, 'Ghế Imax', 0),
(700, 'H5', 61, 2, 'Ghế Imax', 0),
(701, 'H6', 61, 2, 'Ghế Imax', 0),
(702, 'H7', 61, 2, 'Ghế Imax', 0),
(703, 'H8', 61, 2, 'Ghế Imax', 0),
(704, 'H9', 61, 2, 'Ghế Imax', 0),
(705, 'H10', 61, 2, 'Ghế Imax', 0),
(706, 'H11', 61, 2, 'Ghế Imax', 0),
(707, 'H12', 61, 2, 'Ghế Imax', 0),
(708, 'I1', 61, 2, 'Ghế Imax', 0),
(709, 'I2', 61, 2, 'Ghế Imax', 0),
(710, 'I3', 61, 2, 'Ghế Imax', 0),
(711, 'I4', 61, 2, 'Ghế Imax', 0),
(712, 'I5', 61, 2, 'Ghế Imax', 0),
(713, 'I6', 61, 2, 'Ghế Imax', 0),
(714, 'I7', 61, 2, 'Ghế Imax', 0),
(715, 'I8', 61, 2, 'Ghế Imax', 0),
(716, 'I9', 61, 2, 'Ghế Imax', 0),
(717, 'I10', 61, 2, 'Ghế Imax', 0),
(718, 'I11', 61, 2, 'Ghế Imax', 0),
(719, 'I12', 61, 2, 'Ghế Imax', 0),
(720, 'J1', 61, 2, 'Ghế Imax', 0),
(721, 'J2', 61, 2, 'Ghế Imax', 0),
(722, 'J3', 61, 2, 'Ghế Imax', 0),
(723, 'J4', 61, 2, 'Ghế Imax', 0),
(724, 'J5', 61, 2, 'Ghế Imax', 0),
(725, 'J6', 61, 2, 'Ghế Imax', 0),
(726, 'J7', 61, 2, 'Ghế Imax', 0),
(727, 'J8', 61, 2, 'Ghế Imax', 0),
(728, 'J9', 61, 2, 'Ghế Imax', 0),
(729, 'J10', 61, 2, 'Ghế Imax', 0),
(730, 'J11', 61, 2, 'Ghế Imax', 0),
(731, 'J12', 61, 2, 'Ghế Imax', 0),
(732, 'A1', 62, 2, 'Ghế Thường', 0),
(733, 'A2', 62, 2, 'Ghế Thường', 0),
(734, 'A3', 62, 2, 'Ghế Thường', 0),
(735, 'A4', 62, 2, 'Ghế Thường', 0),
(736, 'A5', 62, 2, 'Ghế Thường', 0),
(737, 'A6', 62, 2, 'Ghế Thường', 0),
(738, 'A7', 62, 2, 'Ghế Thường', 0),
(739, 'A8', 62, 2, 'Ghế Thường', 0),
(740, 'A9', 62, 2, 'Ghế Thường', 0),
(741, 'A10', 62, 2, 'Ghế Thường', 0),
(742, 'A11', 62, 2, 'Ghế Thường', 0),
(743, 'A12', 62, 2, 'Ghế Thường', 0),
(744, 'B1', 62, 2, 'Ghế Thường', 0),
(745, 'B2', 62, 2, 'Ghế Thường', 0),
(746, 'B3', 62, 2, 'Ghế Thường', 0),
(747, 'B4', 62, 2, 'Ghế Thường', 0),
(748, 'B5', 62, 2, 'Ghế Thường', 0),
(749, 'B6', 62, 2, 'Ghế Thường', 0),
(750, 'B7', 62, 2, 'Ghế Thường', 0),
(751, 'B8', 62, 2, 'Ghế Thường', 0),
(752, 'B9', 62, 2, 'Ghế Thường', 0),
(753, 'B10', 62, 2, 'Ghế Thường', 0),
(754, 'B11', 62, 2, 'Ghế Thường', 0),
(755, 'B12', 62, 2, 'Ghế Thường', 0),
(756, 'C1', 62, 2, 'Ghế Thường', 0),
(757, 'C2', 62, 2, 'Ghế Thường', 0),
(758, 'C3', 62, 2, 'Ghế Thường', 0),
(759, 'C4', 62, 2, 'Ghế Thường', 0),
(760, 'C5', 62, 2, 'Ghế Thường', 0),
(761, 'C6', 62, 2, 'Ghế Thường', 0),
(762, 'C7', 62, 2, 'Ghế Thường', 0),
(763, 'C8', 62, 2, 'Ghế Thường', 0),
(764, 'C9', 62, 2, 'Ghế Thường', 0),
(765, 'C10', 62, 2, 'Ghế Thường', 0),
(766, 'C11', 62, 2, 'Ghế Thường', 0),
(767, 'C12', 62, 2, 'Ghế Thường', 0),
(768, 'D1', 62, 2, 'Ghế Thường', 0),
(769, 'D2', 62, 2, 'Ghế Thường', 0),
(770, 'D3', 62, 2, 'Ghế Thường', 0),
(771, 'D4', 62, 2, 'Ghế Thường', 0),
(772, 'D5', 62, 2, 'Ghế Thường', 0),
(773, 'D6', 62, 2, 'Ghế Thường', 0),
(774, 'D7', 62, 2, 'Ghế Thường', 0),
(775, 'D8', 62, 2, 'Ghế Thường', 0),
(776, 'D9', 62, 2, 'Ghế Thường', 0),
(777, 'D10', 62, 2, 'Ghế Thường', 0),
(778, 'D11', 62, 2, 'Ghế Thường', 0),
(779, 'D12', 62, 2, 'Ghế Thường', 0),
(780, 'E1', 62, 2, 'Ghế Thường', 0),
(781, 'E2', 62, 2, 'Ghế Thường', 0),
(782, 'E3', 62, 2, 'Ghế Thường', 0),
(783, 'E4', 62, 2, 'Ghế Thường', 0),
(784, 'E5', 62, 2, 'Ghế Thường', 0),
(785, 'E6', 62, 2, 'Ghế Thường', 0),
(786, 'E7', 62, 2, 'Ghế Thường', 0),
(787, 'E8', 62, 2, 'Ghế Thường', 0),
(788, 'E9', 62, 2, 'Ghế Thường', 0),
(789, 'E10', 62, 2, 'Ghế Thường', 0),
(790, 'E11', 62, 2, 'Ghế Thường', 0),
(791, 'E12', 62, 2, 'Ghế Thường', 0),
(792, 'F1', 62, 2, 'Ghế Thường', 0),
(793, 'F2', 62, 2, 'Ghế Thường', 0),
(794, 'F3', 62, 2, 'Ghế Thường', 0),
(795, 'F4', 62, 2, 'Ghế Thường', 0),
(796, 'F5', 62, 2, 'Ghế Thường', 0),
(797, 'F6', 62, 2, 'Ghế Thường', 0),
(798, 'F7', 62, 2, 'Ghế Thường', 0),
(799, 'F8', 62, 2, 'Ghế Thường', 0),
(800, 'F9', 62, 2, 'Ghế Thường', 0),
(801, 'F10', 62, 2, 'Ghế Thường', 0),
(802, 'F11', 62, 2, 'Ghế Thường', 0),
(803, 'F12', 62, 2, 'Ghế Thường', 0),
(804, 'G1', 62, 2, 'Ghế Thường', 0),
(805, 'G2', 62, 2, 'Ghế Thường', 0),
(806, 'G3', 62, 2, 'Ghế Thường', 0),
(807, 'G4', 62, 2, 'Ghế Thường', 0),
(808, 'G5', 62, 2, 'Ghế Thường', 0),
(809, 'G6', 62, 2, 'Ghế Thường', 0),
(810, 'G7', 62, 2, 'Ghế Thường', 0),
(811, 'G8', 62, 2, 'Ghế Thường', 0),
(812, 'G9', 62, 2, 'Ghế Thường', 0),
(813, 'G10', 62, 2, 'Ghế Thường', 0),
(814, 'G11', 62, 2, 'Ghế Thường', 0),
(815, 'G12', 62, 2, 'Ghế Thường', 0),
(816, 'H1', 62, 2, 'Ghế Thường', 0),
(817, 'H2', 62, 2, 'Ghế Thường', 0),
(818, 'H3', 62, 2, 'Ghế Thường', 0),
(819, 'H4', 62, 2, 'Ghế Thường', 0),
(820, 'H5', 62, 2, 'Ghế Thường', 0),
(821, 'H6', 62, 2, 'Ghế Thường', 0),
(822, 'H7', 62, 2, 'Ghế Thường', 0),
(823, 'H8', 62, 2, 'Ghế Thường', 0),
(824, 'H9', 62, 2, 'Ghế Thường', 0),
(825, 'H10', 62, 2, 'Ghế Thường', 0),
(826, 'H11', 62, 2, 'Ghế Thường', 0),
(827, 'H12', 62, 2, 'Ghế Thường', 0),
(828, 'I1', 62, 2, 'Ghế Thường', 0),
(829, 'I2', 62, 2, 'Ghế Thường', 0),
(830, 'I3', 62, 2, 'Ghế Thường', 0),
(831, 'I4', 62, 2, 'Ghế Thường', 0),
(832, 'I5', 62, 2, 'Ghế Thường', 0),
(833, 'I6', 62, 2, 'Ghế Thường', 0),
(834, 'I7', 62, 2, 'Ghế Thường', 0),
(835, 'I8', 62, 2, 'Ghế Thường', 0),
(836, 'I9', 62, 2, 'Ghế Thường', 0),
(837, 'I10', 62, 2, 'Ghế Thường', 0),
(838, 'I11', 62, 2, 'Ghế Thường', 0),
(839, 'I12', 62, 2, 'Ghế Thường', 0),
(840, 'J1', 62, 2, 'Ghế đôi', 0),
(841, 'J2', 62, 2, 'Ghế đôi', 0),
(842, 'J3', 62, 2, 'Ghế đôi', 0),
(843, 'J4', 62, 2, 'Ghế đôi', 0),
(844, 'J5', 62, 2, 'Ghế đôi', 0),
(845, 'J6', 62, 2, 'Ghế đôi', 0),
(846, 'J7', 62, 2, 'Ghế đôi', 0),
(847, 'J8', 62, 2, 'Ghế đôi', 0),
(848, 'J9', 62, 2, 'Ghế đôi', 0),
(849, 'J10', 62, 2, 'Ghế đôi', 0),
(850, 'J11', 62, 2, 'Ghế đôi', 0),
(851, 'J12', 62, 2, 'Ghế đôi', 0),
(852, 'A1', 63, 2, 'Ghế 4DX', 0),
(853, 'A2', 63, 2, 'Ghế 4DX', 0),
(854, 'A3', 63, 2, 'Ghế 4DX', 0),
(855, 'A4', 63, 2, 'Ghế 4DX', 0),
(856, 'A5', 63, 2, 'Ghế 4DX', 0),
(857, 'A6', 63, 2, 'Ghế 4DX', 0),
(858, 'A7', 63, 2, 'Ghế 4DX', 0),
(859, 'A8', 63, 2, 'Ghế 4DX', 0),
(860, 'A9', 63, 2, 'Ghế 4DX', 0),
(861, 'A10', 63, 2, 'Ghế 4DX', 0),
(862, 'A11', 63, 2, 'Ghế 4DX', 0),
(863, 'A12', 63, 2, 'Ghế 4DX', 0),
(864, 'B1', 63, 2, 'Ghế 4DX', 0),
(865, 'B2', 63, 2, 'Ghế 4DX', 0),
(866, 'B3', 63, 2, 'Ghế 4DX', 0),
(867, 'B4', 63, 2, 'Ghế 4DX', 0),
(868, 'B5', 63, 2, 'Ghế 4DX', 0),
(869, 'B6', 63, 2, 'Ghế 4DX', 0),
(870, 'B7', 63, 2, 'Ghế 4DX', 0),
(871, 'B8', 63, 2, 'Ghế 4DX', 0),
(872, 'B9', 63, 2, 'Ghế 4DX', 0),
(873, 'B10', 63, 2, 'Ghế 4DX', 0),
(874, 'B11', 63, 2, 'Ghế 4DX', 0),
(875, 'B12', 63, 2, 'Ghế 4DX', 0),
(876, 'C1', 63, 2, 'Ghế 4DX', 0),
(877, 'C2', 63, 2, 'Ghế 4DX', 0),
(878, 'C3', 63, 2, 'Ghế 4DX', 0),
(879, 'C4', 63, 2, 'Ghế 4DX', 0),
(880, 'C5', 63, 2, 'Ghế 4DX', 0),
(881, 'C6', 63, 2, 'Ghế 4DX', 0),
(882, 'C7', 63, 2, 'Ghế 4DX', 0),
(883, 'C8', 63, 2, 'Ghế 4DX', 0),
(884, 'C9', 63, 2, 'Ghế 4DX', 0),
(885, 'C10', 63, 2, 'Ghế 4DX', 0),
(886, 'C11', 63, 2, 'Ghế 4DX', 0),
(887, 'C12', 63, 2, 'Ghế 4DX', 0),
(888, 'D1', 63, 2, 'Ghế 4DX', 0),
(889, 'D2', 63, 2, 'Ghế 4DX', 0),
(890, 'D3', 63, 2, 'Ghế 4DX', 0),
(891, 'D4', 63, 2, 'Ghế 4DX', 0),
(892, 'D5', 63, 2, 'Ghế 4DX', 0),
(893, 'D6', 63, 2, 'Ghế 4DX', 0),
(894, 'D7', 63, 2, 'Ghế 4DX', 0),
(895, 'D8', 63, 2, 'Ghế 4DX', 0),
(896, 'D9', 63, 2, 'Ghế 4DX', 0),
(897, 'D10', 63, 2, 'Ghế 4DX', 0),
(898, 'D11', 63, 2, 'Ghế 4DX', 0),
(899, 'D12', 63, 2, 'Ghế 4DX', 0),
(900, 'E1', 63, 2, 'Ghế 4DX', 0),
(901, 'E2', 63, 2, 'Ghế 4DX', 0),
(902, 'E3', 63, 2, 'Ghế 4DX', 0),
(903, 'E4', 63, 2, 'Ghế 4DX', 0),
(904, 'E5', 63, 2, 'Ghế 4DX', 0),
(905, 'E6', 63, 2, 'Ghế 4DX', 0),
(906, 'E7', 63, 2, 'Ghế 4DX', 0),
(907, 'E8', 63, 2, 'Ghế 4DX', 0),
(908, 'E9', 63, 2, 'Ghế 4DX', 0),
(909, 'E10', 63, 2, 'Ghế 4DX', 0),
(910, 'E11', 63, 2, 'Ghế 4DX', 0),
(911, 'E12', 63, 2, 'Ghế 4DX', 0),
(912, 'F1', 63, 2, 'Ghế 4DX', 0),
(913, 'F2', 63, 2, 'Ghế 4DX', 0),
(914, 'F3', 63, 2, 'Ghế 4DX', 0),
(915, 'F4', 63, 2, 'Ghế 4DX', 0),
(916, 'F5', 63, 2, 'Ghế 4DX', 0),
(917, 'F6', 63, 2, 'Ghế 4DX', 0),
(918, 'F7', 63, 2, 'Ghế 4DX', 0),
(919, 'F8', 63, 2, 'Ghế 4DX', 0),
(920, 'F9', 63, 2, 'Ghế 4DX', 0),
(921, 'F10', 63, 2, 'Ghế 4DX', 0),
(922, 'F11', 63, 2, 'Ghế 4DX', 0),
(923, 'F12', 63, 2, 'Ghế 4DX', 0),
(924, 'G1', 63, 2, 'Ghế 4DX', 0),
(925, 'G2', 63, 2, 'Ghế 4DX', 0),
(926, 'G3', 63, 2, 'Ghế 4DX', 0),
(927, 'G4', 63, 2, 'Ghế 4DX', 0),
(928, 'G5', 63, 2, 'Ghế 4DX', 0),
(929, 'G6', 63, 2, 'Ghế 4DX', 0),
(930, 'G7', 63, 2, 'Ghế 4DX', 0),
(931, 'G8', 63, 2, 'Ghế 4DX', 0),
(932, 'G9', 63, 2, 'Ghế 4DX', 0),
(933, 'G10', 63, 2, 'Ghế 4DX', 0),
(934, 'G11', 63, 2, 'Ghế 4DX', 0),
(935, 'G12', 63, 2, 'Ghế 4DX', 0),
(936, 'H1', 63, 2, 'Ghế 4DX', 0),
(937, 'H2', 63, 2, 'Ghế 4DX', 0),
(938, 'H3', 63, 2, 'Ghế 4DX', 0),
(939, 'H4', 63, 2, 'Ghế 4DX', 0),
(940, 'H5', 63, 2, 'Ghế 4DX', 0),
(941, 'H6', 63, 2, 'Ghế 4DX', 0),
(942, 'H7', 63, 2, 'Ghế 4DX', 0),
(943, 'H8', 63, 2, 'Ghế 4DX', 0),
(944, 'H9', 63, 2, 'Ghế 4DX', 0),
(945, 'H10', 63, 2, 'Ghế 4DX', 0),
(946, 'H11', 63, 2, 'Ghế 4DX', 0),
(947, 'H12', 63, 2, 'Ghế 4DX', 0),
(948, 'I1', 63, 2, 'Ghế 4DX', 0),
(949, 'I2', 63, 2, 'Ghế 4DX', 0),
(950, 'I3', 63, 2, 'Ghế 4DX', 0),
(951, 'I4', 63, 2, 'Ghế 4DX', 0),
(952, 'I5', 63, 2, 'Ghế 4DX', 0),
(953, 'I6', 63, 2, 'Ghế 4DX', 0),
(954, 'I7', 63, 2, 'Ghế 4DX', 0),
(955, 'I8', 63, 2, 'Ghế 4DX', 0),
(956, 'I9', 63, 2, 'Ghế 4DX', 0),
(957, 'I10', 63, 2, 'Ghế 4DX', 0),
(958, 'I11', 63, 2, 'Ghế 4DX', 0),
(959, 'I12', 63, 2, 'Ghế 4DX', 0),
(960, 'J1', 63, 2, 'Ghế 4DX', 0),
(961, 'J2', 63, 2, 'Ghế 4DX', 0),
(962, 'J3', 63, 2, 'Ghế 4DX', 0),
(963, 'J4', 63, 2, 'Ghế 4DX', 0),
(964, 'J5', 63, 2, 'Ghế 4DX', 0),
(965, 'J6', 63, 2, 'Ghế 4DX', 0),
(966, 'J7', 63, 2, 'Ghế 4DX', 0),
(967, 'J8', 63, 2, 'Ghế 4DX', 0),
(968, 'J9', 63, 2, 'Ghế 4DX', 0),
(969, 'J10', 63, 2, 'Ghế 4DX', 0),
(970, 'J11', 63, 2, 'Ghế 4DX', 0),
(971, 'J12', 63, 2, 'Ghế 4DX', 0),
(972, 'A1', 64, 3, 'Ghế Thường', 0),
(973, 'A2', 64, 3, 'Ghế Thường', 0),
(974, 'A3', 64, 3, 'Ghế Thường', 0),
(975, 'A4', 64, 3, 'Ghế Thường', 0),
(976, 'A5', 64, 3, 'Ghế Thường', 0),
(977, 'A6', 64, 3, 'Ghế Thường', 0),
(978, 'A7', 64, 3, 'Ghế Thường', 0),
(979, 'A8', 64, 3, 'Ghế Thường', 0),
(980, 'A9', 64, 3, 'Ghế Thường', 0),
(981, 'A10', 64, 3, 'Ghế Thường', 0),
(982, 'A11', 64, 3, 'Ghế Thường', 0),
(983, 'A12', 64, 3, 'Ghế Thường', 0),
(984, 'B1', 64, 3, 'Ghế Thường', 0),
(985, 'B2', 64, 3, 'Ghế Thường', 0),
(986, 'B3', 64, 3, 'Ghế Thường', 0),
(987, 'B4', 64, 3, 'Ghế Thường', 0),
(988, 'B5', 64, 3, 'Ghế Thường', 0),
(989, 'B6', 64, 3, 'Ghế Thường', 0),
(990, 'B7', 64, 3, 'Ghế Thường', 0),
(991, 'B8', 64, 3, 'Ghế Thường', 0),
(992, 'B9', 64, 3, 'Ghế Thường', 0),
(993, 'B10', 64, 3, 'Ghế Thường', 0),
(994, 'B11', 64, 3, 'Ghế Thường', 0),
(995, 'B12', 64, 3, 'Ghế Thường', 0),
(996, 'C1', 64, 3, 'Ghế Thường', 0),
(997, 'C2', 64, 3, 'Ghế Thường', 0),
(998, 'C3', 64, 3, 'Ghế Thường', 0),
(999, 'C4', 64, 3, 'Ghế Thường', 0),
(1000, 'C5', 64, 3, 'Ghế Thường', 0),
(1001, 'C6', 64, 3, 'Ghế Thường', 0),
(1002, 'C7', 64, 3, 'Ghế Thường', 0),
(1003, 'C8', 64, 3, 'Ghế Thường', 0),
(1004, 'C9', 64, 3, 'Ghế Thường', 0),
(1005, 'C10', 64, 3, 'Ghế Thường', 0),
(1006, 'C11', 64, 3, 'Ghế Thường', 0),
(1007, 'C12', 64, 3, 'Ghế Thường', 0),
(1008, 'D1', 64, 3, 'Ghế Thường', 0),
(1009, 'D2', 64, 3, 'Ghế Thường', 0),
(1010, 'D3', 64, 3, 'Ghế Thường', 0),
(1011, 'D4', 64, 3, 'Ghế Thường', 0),
(1012, 'D5', 64, 3, 'Ghế Thường', 0),
(1013, 'D6', 64, 3, 'Ghế Thường', 0),
(1014, 'D7', 64, 3, 'Ghế Thường', 0),
(1015, 'D8', 64, 3, 'Ghế Thường', 0),
(1016, 'D9', 64, 3, 'Ghế Thường', 0),
(1017, 'D10', 64, 3, 'Ghế Thường', 0),
(1018, 'D11', 64, 3, 'Ghế Thường', 0),
(1019, 'D12', 64, 3, 'Ghế Thường', 0),
(1020, 'E1', 64, 3, 'Ghế Thường', 0),
(1021, 'E2', 64, 3, 'Ghế Thường', 0),
(1022, 'E3', 64, 3, 'Ghế Thường', 0),
(1023, 'E4', 64, 3, 'Ghế Thường', 0),
(1024, 'E5', 64, 3, 'Ghế Thường', 0),
(1025, 'E6', 64, 3, 'Ghế Thường', 1),
(1026, 'E7', 64, 3, 'Ghế Thường', 1),
(1027, 'E8', 64, 3, 'Ghế Thường', 0),
(1028, 'E9', 64, 3, 'Ghế Thường', 0),
(1029, 'E10', 64, 3, 'Ghế Thường', 0),
(1030, 'E11', 64, 3, 'Ghế Thường', 0),
(1031, 'E12', 64, 3, 'Ghế Thường', 0),
(1032, 'F1', 64, 3, 'Ghế Thường', 0),
(1033, 'F2', 64, 3, 'Ghế Thường', 0),
(1034, 'F3', 64, 3, 'Ghế Thường', 0),
(1035, 'F4', 64, 3, 'Ghế Thường', 0),
(1036, 'F5', 64, 3, 'Ghế Thường', 1),
(1037, 'F6', 64, 3, 'Ghế Thường', 0),
(1038, 'F7', 64, 3, 'Ghế Thường', 0),
(1039, 'F8', 64, 3, 'Ghế Thường', 0),
(1040, 'F9', 64, 3, 'Ghế Thường', 1),
(1041, 'F10', 64, 3, 'Ghế Thường', 0),
(1042, 'F11', 64, 3, 'Ghế Thường', 0),
(1043, 'F12', 64, 3, 'Ghế Thường', 0),
(1044, 'G1', 64, 3, 'Ghế Thường', 0),
(1045, 'G2', 64, 3, 'Ghế Thường', 0),
(1046, 'G3', 64, 3, 'Ghế Thường', 0),
(1047, 'G4', 64, 3, 'Ghế Thường', 0),
(1048, 'G5', 64, 3, 'Ghế Thường', 0),
(1049, 'G6', 64, 3, 'Ghế Thường', 0),
(1050, 'G7', 64, 3, 'Ghế Thường', 1),
(1051, 'G8', 64, 3, 'Ghế Thường', 0),
(1052, 'G9', 64, 3, 'Ghế Thường', 0),
(1053, 'G10', 64, 3, 'Ghế Thường', 0),
(1054, 'G11', 64, 3, 'Ghế Thường', 0),
(1055, 'G12', 64, 3, 'Ghế Thường', 0),
(1056, 'H1', 64, 3, 'Ghế Thường', 0),
(1057, 'H2', 64, 3, 'Ghế Thường', 0),
(1058, 'H3', 64, 3, 'Ghế Thường', 0),
(1059, 'H4', 64, 3, 'Ghế Thường', 0),
(1060, 'H5', 64, 3, 'Ghế Thường', 0),
(1061, 'H6', 64, 3, 'Ghế Thường', 0),
(1062, 'H7', 64, 3, 'Ghế Thường', 0),
(1063, 'H8', 64, 3, 'Ghế Thường', 0),
(1064, 'H9', 64, 3, 'Ghế Thường', 0),
(1065, 'H10', 64, 3, 'Ghế Thường', 0),
(1066, 'H11', 64, 3, 'Ghế Thường', 0),
(1067, 'H12', 64, 3, 'Ghế Thường', 0),
(1068, 'I1', 64, 3, 'Ghế Thường', 0),
(1069, 'I2', 64, 3, 'Ghế Thường', 0),
(1070, 'I3', 64, 3, 'Ghế Thường', 0),
(1071, 'I4', 64, 3, 'Ghế Thường', 0),
(1072, 'I5', 64, 3, 'Ghế Thường', 0),
(1073, 'I6', 64, 3, 'Ghế Thường', 0),
(1074, 'I7', 64, 3, 'Ghế Thường', 0),
(1075, 'I8', 64, 3, 'Ghế Thường', 0),
(1076, 'I9', 64, 3, 'Ghế Thường', 0),
(1077, 'I10', 64, 3, 'Ghế Thường', 0),
(1078, 'I11', 64, 3, 'Ghế Thường', 0),
(1079, 'I12', 64, 3, 'Ghế Thường', 0),
(1080, 'J1', 64, 3, 'Ghế đôi', 0),
(1081, 'J2', 64, 3, 'Ghế đôi', 0),
(1082, 'J3', 64, 3, 'Ghế đôi', 0),
(1083, 'J4', 64, 3, 'Ghế đôi', 0),
(1084, 'J5', 64, 3, 'Ghế đôi', 0),
(1085, 'J6', 64, 3, 'Ghế đôi', 0),
(1086, 'J7', 64, 3, 'Ghế đôi', 0),
(1087, 'J8', 64, 3, 'Ghế đôi', 0),
(1088, 'J9', 64, 3, 'Ghế đôi', 0),
(1089, 'J10', 64, 3, 'Ghế đôi', 0),
(1090, 'J11', 64, 3, 'Ghế đôi', 0),
(1091, 'J12', 64, 3, 'Ghế đôi', 0),
(1092, 'A1', 65, 3, 'Gold Class', 0),
(1093, 'A2', 65, 3, 'Gold Class', 0),
(1094, 'A3', 65, 3, 'Gold Class', 0),
(1095, 'A4', 65, 3, 'Gold Class', 0),
(1096, 'A5', 65, 3, 'Gold Class', 0),
(1097, 'A6', 65, 3, 'Gold Class', 0),
(1098, 'A7', 65, 3, 'Gold Class', 0),
(1099, 'A8', 65, 3, 'Gold Class', 0),
(1100, 'A9', 65, 3, 'Gold Class', 0),
(1101, 'A10', 65, 3, 'Gold Class', 0),
(1102, 'A11', 65, 3, 'Gold Class', 0),
(1103, 'A12', 65, 3, 'Gold Class', 0),
(1104, 'B1', 65, 3, 'Gold Class', 0),
(1105, 'B2', 65, 3, 'Gold Class', 0),
(1106, 'B3', 65, 3, 'Gold Class', 0),
(1107, 'B4', 65, 3, 'Gold Class', 0),
(1108, 'B5', 65, 3, 'Gold Class', 0),
(1109, 'B6', 65, 3, 'Gold Class', 0),
(1110, 'B7', 65, 3, 'Gold Class', 0),
(1111, 'B8', 65, 3, 'Gold Class', 0),
(1112, 'B9', 65, 3, 'Gold Class', 0),
(1113, 'B10', 65, 3, 'Gold Class', 0),
(1114, 'B11', 65, 3, 'Gold Class', 0),
(1115, 'B12', 65, 3, 'Gold Class', 0),
(1116, 'C1', 65, 3, 'Gold Class', 0),
(1117, 'C2', 65, 3, 'Gold Class', 0),
(1118, 'C3', 65, 3, 'Gold Class', 0),
(1119, 'C4', 65, 3, 'Gold Class', 0),
(1120, 'C5', 65, 3, 'Gold Class', 0),
(1121, 'C6', 65, 3, 'Gold Class', 0),
(1122, 'C7', 65, 3, 'Gold Class', 0),
(1123, 'C8', 65, 3, 'Gold Class', 0),
(1124, 'C9', 65, 3, 'Gold Class', 0),
(1125, 'C10', 65, 3, 'Gold Class', 0),
(1126, 'C11', 65, 3, 'Gold Class', 0),
(1127, 'C12', 65, 3, 'Gold Class', 0),
(1128, 'D1', 65, 3, 'Gold Class', 0),
(1129, 'D2', 65, 3, 'Gold Class', 0),
(1130, 'D3', 65, 3, 'Gold Class', 0),
(1131, 'D4', 65, 3, 'Gold Class', 0),
(1132, 'D5', 65, 3, 'Gold Class', 0),
(1133, 'D6', 65, 3, 'Gold Class', 0),
(1134, 'D7', 65, 3, 'Gold Class', 0),
(1135, 'D8', 65, 3, 'Gold Class', 0),
(1136, 'D9', 65, 3, 'Gold Class', 0),
(1137, 'D10', 65, 3, 'Gold Class', 0),
(1138, 'D11', 65, 3, 'Gold Class', 0),
(1139, 'D12', 65, 3, 'Gold Class', 0),
(1140, 'E1', 65, 3, 'Gold Class', 0),
(1141, 'E2', 65, 3, 'Gold Class', 0),
(1142, 'E3', 65, 3, 'Gold Class', 0),
(1143, 'E4', 65, 3, 'Gold Class', 0),
(1144, 'E5', 65, 3, 'Gold Class', 0),
(1145, 'E6', 65, 3, 'Gold Class', 0),
(1146, 'E7', 65, 3, 'Gold Class', 0),
(1147, 'E8', 65, 3, 'Gold Class', 0),
(1148, 'E9', 65, 3, 'Gold Class', 0),
(1149, 'E10', 65, 3, 'Gold Class', 0),
(1150, 'E11', 65, 3, 'Gold Class', 0),
(1151, 'E12', 65, 3, 'Gold Class', 0),
(1152, 'F1', 65, 3, 'Gold Class', 0),
(1153, 'F2', 65, 3, 'Gold Class', 0),
(1154, 'F3', 65, 3, 'Gold Class', 0),
(1155, 'F4', 65, 3, 'Gold Class', 0),
(1156, 'F5', 65, 3, 'Gold Class', 0),
(1157, 'F6', 65, 3, 'Gold Class', 0),
(1158, 'F7', 65, 3, 'Gold Class', 0),
(1159, 'F8', 65, 3, 'Gold Class', 0),
(1160, 'F9', 65, 3, 'Gold Class', 0),
(1161, 'F10', 65, 3, 'Gold Class', 0),
(1162, 'F11', 65, 3, 'Gold Class', 0),
(1163, 'F12', 65, 3, 'Gold Class', 0),
(1164, 'G1', 65, 3, 'Gold Class', 0),
(1165, 'G2', 65, 3, 'Gold Class', 0),
(1166, 'G3', 65, 3, 'Gold Class', 0),
(1167, 'G4', 65, 3, 'Gold Class', 0),
(1168, 'G5', 65, 3, 'Gold Class', 0),
(1169, 'G6', 65, 3, 'Gold Class', 0),
(1170, 'G7', 65, 3, 'Gold Class', 0),
(1171, 'G8', 65, 3, 'Gold Class', 0),
(1172, 'G9', 65, 3, 'Gold Class', 0),
(1173, 'G10', 65, 3, 'Gold Class', 0),
(1174, 'G11', 65, 3, 'Gold Class', 0),
(1175, 'G12', 65, 3, 'Gold Class', 0),
(1176, 'H1', 65, 3, 'Gold Class', 0),
(1177, 'H2', 65, 3, 'Gold Class', 0),
(1178, 'H3', 65, 3, 'Gold Class', 0),
(1179, 'H4', 65, 3, 'Gold Class', 0),
(1180, 'H5', 65, 3, 'Gold Class', 0),
(1181, 'H6', 65, 3, 'Gold Class', 0),
(1182, 'H7', 65, 3, 'Gold Class', 0),
(1183, 'H8', 65, 3, 'Gold Class', 0),
(1184, 'H9', 65, 3, 'Gold Class', 0),
(1185, 'H10', 65, 3, 'Gold Class', 0),
(1186, 'H11', 65, 3, 'Gold Class', 0),
(1187, 'H12', 65, 3, 'Gold Class', 0),
(1188, 'I1', 65, 3, 'Gold Class', 0),
(1189, 'I2', 65, 3, 'Gold Class', 0),
(1190, 'I3', 65, 3, 'Gold Class', 0),
(1191, 'I4', 65, 3, 'Gold Class', 0),
(1192, 'I5', 65, 3, 'Gold Class', 0),
(1193, 'I6', 65, 3, 'Gold Class', 0),
(1194, 'I7', 65, 3, 'Gold Class', 0),
(1195, 'I8', 65, 3, 'Gold Class', 0),
(1196, 'I9', 65, 3, 'Gold Class', 0),
(1197, 'I10', 65, 3, 'Gold Class', 0),
(1198, 'I11', 65, 3, 'Gold Class', 0),
(1199, 'I12', 65, 3, 'Gold Class', 0),
(1200, 'J1', 65, 3, 'Gold Class', 0),
(1201, 'J2', 65, 3, 'Gold Class', 0),
(1202, 'J3', 65, 3, 'Gold Class', 0),
(1203, 'J4', 65, 3, 'Gold Class', 0),
(1204, 'J5', 65, 3, 'Gold Class', 0),
(1205, 'J6', 65, 3, 'Gold Class', 0),
(1206, 'J7', 65, 3, 'Gold Class', 0),
(1207, 'J8', 65, 3, 'Gold Class', 0),
(1208, 'J9', 65, 3, 'Gold Class', 0),
(1209, 'J10', 65, 3, 'Gold Class', 0),
(1210, 'J11', 65, 3, 'Gold Class', 0),
(1211, 'J12', 65, 3, 'Gold Class', 0),
(1212, 'A1', 66, 3, 'Ghế 4DX', 0),
(1213, 'A2', 66, 3, 'Ghế 4DX', 0),
(1214, 'A3', 66, 3, 'Ghế 4DX', 0),
(1215, 'A4', 66, 3, 'Ghế 4DX', 0),
(1216, 'A5', 66, 3, 'Ghế 4DX', 0),
(1217, 'A6', 66, 3, 'Ghế 4DX', 0),
(1218, 'A7', 66, 3, 'Ghế 4DX', 0),
(1219, 'A8', 66, 3, 'Ghế 4DX', 0),
(1220, 'A9', 66, 3, 'Ghế 4DX', 0),
(1221, 'A10', 66, 3, 'Ghế 4DX', 0),
(1222, 'A11', 66, 3, 'Ghế 4DX', 0),
(1223, 'A12', 66, 3, 'Ghế 4DX', 0),
(1224, 'B1', 66, 3, 'Ghế 4DX', 0),
(1225, 'B2', 66, 3, 'Ghế 4DX', 0),
(1226, 'B3', 66, 3, 'Ghế 4DX', 0),
(1227, 'B4', 66, 3, 'Ghế 4DX', 0),
(1228, 'B5', 66, 3, 'Ghế 4DX', 0),
(1229, 'B6', 66, 3, 'Ghế 4DX', 0),
(1230, 'B7', 66, 3, 'Ghế 4DX', 0),
(1231, 'B8', 66, 3, 'Ghế 4DX', 0),
(1232, 'B9', 66, 3, 'Ghế 4DX', 0),
(1233, 'B10', 66, 3, 'Ghế 4DX', 0),
(1234, 'B11', 66, 3, 'Ghế 4DX', 0),
(1235, 'B12', 66, 3, 'Ghế 4DX', 0),
(1236, 'C1', 66, 3, 'Ghế 4DX', 0),
(1237, 'C2', 66, 3, 'Ghế 4DX', 0),
(1238, 'C3', 66, 3, 'Ghế 4DX', 0),
(1239, 'C4', 66, 3, 'Ghế 4DX', 0),
(1240, 'C5', 66, 3, 'Ghế 4DX', 0),
(1241, 'C6', 66, 3, 'Ghế 4DX', 0),
(1242, 'C7', 66, 3, 'Ghế 4DX', 0),
(1243, 'C8', 66, 3, 'Ghế 4DX', 0),
(1244, 'C9', 66, 3, 'Ghế 4DX', 0),
(1245, 'C10', 66, 3, 'Ghế 4DX', 0),
(1246, 'C11', 66, 3, 'Ghế 4DX', 0),
(1247, 'C12', 66, 3, 'Ghế 4DX', 0),
(1248, 'D1', 66, 3, 'Ghế 4DX', 0),
(1249, 'D2', 66, 3, 'Ghế 4DX', 0),
(1250, 'D3', 66, 3, 'Ghế 4DX', 0),
(1251, 'D4', 66, 3, 'Ghế 4DX', 0),
(1252, 'D5', 66, 3, 'Ghế 4DX', 0),
(1253, 'D6', 66, 3, 'Ghế 4DX', 0),
(1254, 'D7', 66, 3, 'Ghế 4DX', 0),
(1255, 'D8', 66, 3, 'Ghế 4DX', 0),
(1256, 'D9', 66, 3, 'Ghế 4DX', 0),
(1257, 'D10', 66, 3, 'Ghế 4DX', 0),
(1258, 'D11', 66, 3, 'Ghế 4DX', 0),
(1259, 'D12', 66, 3, 'Ghế 4DX', 0),
(1260, 'E1', 66, 3, 'Ghế 4DX', 0),
(1261, 'E2', 66, 3, 'Ghế 4DX', 0),
(1262, 'E3', 66, 3, 'Ghế 4DX', 0),
(1263, 'E4', 66, 3, 'Ghế 4DX', 0),
(1264, 'E5', 66, 3, 'Ghế 4DX', 0),
(1265, 'E6', 66, 3, 'Ghế 4DX', 0),
(1266, 'E7', 66, 3, 'Ghế 4DX', 0),
(1267, 'E8', 66, 3, 'Ghế 4DX', 0),
(1268, 'E9', 66, 3, 'Ghế 4DX', 0),
(1269, 'E10', 66, 3, 'Ghế 4DX', 0),
(1270, 'E11', 66, 3, 'Ghế 4DX', 0),
(1271, 'E12', 66, 3, 'Ghế 4DX', 0),
(1272, 'F1', 66, 3, 'Ghế 4DX', 0),
(1273, 'F2', 66, 3, 'Ghế 4DX', 0),
(1274, 'F3', 66, 3, 'Ghế 4DX', 0),
(1275, 'F4', 66, 3, 'Ghế 4DX', 0),
(1276, 'F5', 66, 3, 'Ghế 4DX', 0),
(1277, 'F6', 66, 3, 'Ghế 4DX', 0),
(1278, 'F7', 66, 3, 'Ghế 4DX', 0),
(1279, 'F8', 66, 3, 'Ghế 4DX', 0),
(1280, 'F9', 66, 3, 'Ghế 4DX', 0),
(1281, 'F10', 66, 3, 'Ghế 4DX', 0),
(1282, 'F11', 66, 3, 'Ghế 4DX', 0),
(1283, 'F12', 66, 3, 'Ghế 4DX', 0),
(1284, 'G1', 66, 3, 'Ghế 4DX', 0),
(1285, 'G2', 66, 3, 'Ghế 4DX', 0),
(1286, 'G3', 66, 3, 'Ghế 4DX', 0),
(1287, 'G4', 66, 3, 'Ghế 4DX', 0),
(1288, 'G5', 66, 3, 'Ghế 4DX', 0),
(1289, 'G6', 66, 3, 'Ghế 4DX', 0),
(1290, 'G7', 66, 3, 'Ghế 4DX', 0),
(1291, 'G8', 66, 3, 'Ghế 4DX', 0),
(1292, 'G9', 66, 3, 'Ghế 4DX', 0),
(1293, 'G10', 66, 3, 'Ghế 4DX', 0),
(1294, 'G11', 66, 3, 'Ghế 4DX', 0),
(1295, 'G12', 66, 3, 'Ghế 4DX', 0),
(1296, 'H1', 66, 3, 'Ghế 4DX', 0),
(1297, 'H2', 66, 3, 'Ghế 4DX', 0),
(1298, 'H3', 66, 3, 'Ghế 4DX', 0),
(1299, 'H4', 66, 3, 'Ghế 4DX', 0),
(1300, 'H5', 66, 3, 'Ghế 4DX', 0),
(1301, 'H6', 66, 3, 'Ghế 4DX', 0),
(1302, 'H7', 66, 3, 'Ghế 4DX', 0),
(1303, 'H8', 66, 3, 'Ghế 4DX', 0),
(1304, 'H9', 66, 3, 'Ghế 4DX', 0),
(1305, 'H10', 66, 3, 'Ghế 4DX', 0),
(1306, 'H11', 66, 3, 'Ghế 4DX', 0),
(1307, 'H12', 66, 3, 'Ghế 4DX', 0),
(1308, 'I1', 66, 3, 'Ghế 4DX', 0),
(1309, 'I2', 66, 3, 'Ghế 4DX', 0),
(1310, 'I3', 66, 3, 'Ghế 4DX', 0),
(1311, 'I4', 66, 3, 'Ghế 4DX', 0),
(1312, 'I5', 66, 3, 'Ghế 4DX', 0),
(1313, 'I6', 66, 3, 'Ghế 4DX', 0),
(1314, 'I7', 66, 3, 'Ghế 4DX', 0),
(1315, 'I8', 66, 3, 'Ghế 4DX', 0),
(1316, 'I9', 66, 3, 'Ghế 4DX', 0),
(1317, 'I10', 66, 3, 'Ghế 4DX', 0),
(1318, 'I11', 66, 3, 'Ghế 4DX', 0),
(1319, 'I12', 66, 3, 'Ghế 4DX', 0),
(1320, 'J1', 66, 3, 'Ghế 4DX', 0),
(1321, 'J2', 66, 3, 'Ghế 4DX', 0),
(1322, 'J3', 66, 3, 'Ghế 4DX', 0),
(1323, 'J4', 66, 3, 'Ghế 4DX', 0),
(1324, 'J5', 66, 3, 'Ghế 4DX', 0),
(1325, 'J6', 66, 3, 'Ghế 4DX', 0),
(1326, 'J7', 66, 3, 'Ghế 4DX', 0),
(1327, 'J8', 66, 3, 'Ghế 4DX', 0),
(1328, 'J9', 66, 3, 'Ghế 4DX', 0),
(1329, 'J10', 66, 3, 'Ghế 4DX', 0),
(1330, 'J11', 66, 3, 'Ghế 4DX', 0),
(1331, 'J12', 66, 3, 'Ghế 4DX', 0),
(1332, 'A1', 67, 4, 'Ghế Thường', 0),
(1333, 'A2', 67, 4, 'Ghế Thường', 0),
(1334, 'A3', 67, 4, 'Ghế Thường', 0),
(1335, 'A4', 67, 4, 'Ghế Thường', 0),
(1336, 'A5', 67, 4, 'Ghế Thường', 0),
(1337, 'A6', 67, 4, 'Ghế Thường', 0),
(1338, 'A7', 67, 4, 'Ghế Thường', 0),
(1339, 'A8', 67, 4, 'Ghế Thường', 0),
(1340, 'A9', 67, 4, 'Ghế Thường', 0),
(1341, 'A10', 67, 4, 'Ghế Thường', 0),
(1342, 'A11', 67, 4, 'Ghế Thường', 0),
(1343, 'A12', 67, 4, 'Ghế Thường', 0),
(1344, 'B1', 67, 4, 'Ghế Thường', 0),
(1345, 'B2', 67, 4, 'Ghế Thường', 0),
(1346, 'B3', 67, 4, 'Ghế Thường', 0),
(1347, 'B4', 67, 4, 'Ghế Thường', 0),
(1348, 'B5', 67, 4, 'Ghế Thường', 0),
(1349, 'B6', 67, 4, 'Ghế Thường', 0),
(1350, 'B7', 67, 4, 'Ghế Thường', 0),
(1351, 'B8', 67, 4, 'Ghế Thường', 0),
(1352, 'B9', 67, 4, 'Ghế Thường', 0),
(1353, 'B10', 67, 4, 'Ghế Thường', 0),
(1354, 'B11', 67, 4, 'Ghế Thường', 0),
(1355, 'B12', 67, 4, 'Ghế Thường', 0),
(1356, 'C1', 67, 4, 'Ghế Thường', 0),
(1357, 'C2', 67, 4, 'Ghế Thường', 0),
(1358, 'C3', 67, 4, 'Ghế Thường', 0),
(1359, 'C4', 67, 4, 'Ghế Thường', 0),
(1360, 'C5', 67, 4, 'Ghế Thường', 0),
(1361, 'C6', 67, 4, 'Ghế Thường', 0),
(1362, 'C7', 67, 4, 'Ghế Thường', 0),
(1363, 'C8', 67, 4, 'Ghế Thường', 0),
(1364, 'C9', 67, 4, 'Ghế Thường', 0),
(1365, 'C10', 67, 4, 'Ghế Thường', 0),
(1366, 'C11', 67, 4, 'Ghế Thường', 0),
(1367, 'C12', 67, 4, 'Ghế Thường', 0),
(1368, 'D1', 67, 4, 'Ghế Thường', 0),
(1369, 'D2', 67, 4, 'Ghế Thường', 0),
(1370, 'D3', 67, 4, 'Ghế Thường', 0),
(1371, 'D4', 67, 4, 'Ghế Thường', 0),
(1372, 'D5', 67, 4, 'Ghế Thường', 0),
(1373, 'D6', 67, 4, 'Ghế Thường', 0),
(1374, 'D7', 67, 4, 'Ghế Thường', 0),
(1375, 'D8', 67, 4, 'Ghế Thường', 0),
(1376, 'D9', 67, 4, 'Ghế Thường', 0),
(1377, 'D10', 67, 4, 'Ghế Thường', 0),
(1378, 'D11', 67, 4, 'Ghế Thường', 0),
(1379, 'D12', 67, 4, 'Ghế Thường', 0),
(1380, 'E1', 67, 4, 'Ghế Thường', 0),
(1381, 'E2', 67, 4, 'Ghế Thường', 0),
(1382, 'E3', 67, 4, 'Ghế Thường', 0),
(1383, 'E4', 67, 4, 'Ghế Thường', 0),
(1384, 'E5', 67, 4, 'Ghế Thường', 0),
(1385, 'E6', 67, 4, 'Ghế Thường', 0),
(1386, 'E7', 67, 4, 'Ghế Thường', 0),
(1387, 'E8', 67, 4, 'Ghế Thường', 0),
(1388, 'E9', 67, 4, 'Ghế Thường', 0),
(1389, 'E10', 67, 4, 'Ghế Thường', 0),
(1390, 'E11', 67, 4, 'Ghế Thường', 0),
(1391, 'E12', 67, 4, 'Ghế Thường', 0),
(1392, 'F1', 67, 4, 'Ghế Thường', 0),
(1393, 'F2', 67, 4, 'Ghế Thường', 0),
(1394, 'F3', 67, 4, 'Ghế Thường', 0),
(1395, 'F4', 67, 4, 'Ghế Thường', 0),
(1396, 'F5', 67, 4, 'Ghế Thường', 0),
(1397, 'F6', 67, 4, 'Ghế Thường', 0),
(1398, 'F7', 67, 4, 'Ghế Thường', 0),
(1399, 'F8', 67, 4, 'Ghế Thường', 0),
(1400, 'F9', 67, 4, 'Ghế Thường', 0),
(1401, 'F10', 67, 4, 'Ghế Thường', 0),
(1402, 'F11', 67, 4, 'Ghế Thường', 0),
(1403, 'F12', 67, 4, 'Ghế Thường', 0),
(1404, 'G1', 67, 4, 'Ghế Thường', 0),
(1405, 'G2', 67, 4, 'Ghế Thường', 0),
(1406, 'G3', 67, 4, 'Ghế Thường', 0),
(1407, 'G4', 67, 4, 'Ghế Thường', 0),
(1408, 'G5', 67, 4, 'Ghế Thường', 0),
(1409, 'G6', 67, 4, 'Ghế Thường', 0),
(1410, 'G7', 67, 4, 'Ghế Thường', 0),
(1411, 'G8', 67, 4, 'Ghế Thường', 0),
(1412, 'G9', 67, 4, 'Ghế Thường', 0),
(1413, 'G10', 67, 4, 'Ghế Thường', 0),
(1414, 'G11', 67, 4, 'Ghế Thường', 0),
(1415, 'G12', 67, 4, 'Ghế Thường', 0),
(1416, 'H1', 67, 4, 'Ghế Thường', 0),
(1417, 'H2', 67, 4, 'Ghế Thường', 0),
(1418, 'H3', 67, 4, 'Ghế Thường', 0),
(1419, 'H4', 67, 4, 'Ghế Thường', 0),
(1420, 'H5', 67, 4, 'Ghế Thường', 0),
(1421, 'H6', 67, 4, 'Ghế Thường', 0),
(1422, 'H7', 67, 4, 'Ghế Thường', 0),
(1423, 'H8', 67, 4, 'Ghế Thường', 0),
(1424, 'H9', 67, 4, 'Ghế Thường', 0),
(1425, 'H10', 67, 4, 'Ghế Thường', 0),
(1426, 'H11', 67, 4, 'Ghế Thường', 0),
(1427, 'H12', 67, 4, 'Ghế Thường', 0),
(1428, 'I1', 67, 4, 'Ghế Thường', 0),
(1429, 'I2', 67, 4, 'Ghế Thường', 0),
(1430, 'I3', 67, 4, 'Ghế Thường', 0),
(1431, 'I4', 67, 4, 'Ghế Thường', 0),
(1432, 'I5', 67, 4, 'Ghế Thường', 0),
(1433, 'I6', 67, 4, 'Ghế Thường', 0),
(1434, 'I7', 67, 4, 'Ghế Thường', 0),
(1435, 'I8', 67, 4, 'Ghế Thường', 0),
(1436, 'I9', 67, 4, 'Ghế Thường', 0),
(1437, 'I10', 67, 4, 'Ghế Thường', 0),
(1438, 'I11', 67, 4, 'Ghế Thường', 0),
(1439, 'I12', 67, 4, 'Ghế Thường', 0),
(1440, 'J1', 67, 4, 'Ghế đôi', 0),
(1441, 'J2', 67, 4, 'Ghế đôi', 0),
(1442, 'J3', 67, 4, 'Ghế đôi', 0),
(1443, 'J4', 67, 4, 'Ghế đôi', 0),
(1444, 'J5', 67, 4, 'Ghế đôi', 0),
(1445, 'J6', 67, 4, 'Ghế đôi', 0),
(1446, 'J7', 67, 4, 'Ghế đôi', 0),
(1447, 'J8', 67, 4, 'Ghế đôi', 0),
(1448, 'J9', 67, 4, 'Ghế đôi', 0),
(1449, 'J10', 67, 4, 'Ghế đôi', 0),
(1450, 'J11', 67, 4, 'Ghế đôi', 0),
(1451, 'J12', 67, 4, 'Ghế đôi', 0),
(1452, 'A1', 68, 4, 'Ghế Imax', 0),
(1453, 'A2', 68, 4, 'Ghế Imax', 0),
(1454, 'A3', 68, 4, 'Ghế Imax', 0),
(1455, 'A4', 68, 4, 'Ghế Imax', 0),
(1456, 'A5', 68, 4, 'Ghế Imax', 0),
(1457, 'A6', 68, 4, 'Ghế Imax', 0),
(1458, 'A7', 68, 4, 'Ghế Imax', 0),
(1459, 'A8', 68, 4, 'Ghế Imax', 0),
(1460, 'A9', 68, 4, 'Ghế Imax', 0),
(1461, 'A10', 68, 4, 'Ghế Imax', 0),
(1462, 'A11', 68, 4, 'Ghế Imax', 0),
(1463, 'A12', 68, 4, 'Ghế Imax', 0),
(1464, 'B1', 68, 4, 'Ghế Imax', 0),
(1465, 'B2', 68, 4, 'Ghế Imax', 0),
(1466, 'B3', 68, 4, 'Ghế Imax', 0),
(1467, 'B4', 68, 4, 'Ghế Imax', 0),
(1468, 'B5', 68, 4, 'Ghế Imax', 0),
(1469, 'B6', 68, 4, 'Ghế Imax', 0),
(1470, 'B7', 68, 4, 'Ghế Imax', 0),
(1471, 'B8', 68, 4, 'Ghế Imax', 0),
(1472, 'B9', 68, 4, 'Ghế Imax', 0),
(1473, 'B10', 68, 4, 'Ghế Imax', 0),
(1474, 'B11', 68, 4, 'Ghế Imax', 0),
(1475, 'B12', 68, 4, 'Ghế Imax', 0),
(1476, 'C1', 68, 4, 'Ghế Imax', 0),
(1477, 'C2', 68, 4, 'Ghế Imax', 0),
(1478, 'C3', 68, 4, 'Ghế Imax', 0),
(1479, 'C4', 68, 4, 'Ghế Imax', 0),
(1480, 'C5', 68, 4, 'Ghế Imax', 0),
(1481, 'C6', 68, 4, 'Ghế Imax', 0),
(1482, 'C7', 68, 4, 'Ghế Imax', 0),
(1483, 'C8', 68, 4, 'Ghế Imax', 0),
(1484, 'C9', 68, 4, 'Ghế Imax', 0),
(1485, 'C10', 68, 4, 'Ghế Imax', 0),
(1486, 'C11', 68, 4, 'Ghế Imax', 0),
(1487, 'C12', 68, 4, 'Ghế Imax', 0),
(1488, 'D1', 68, 4, 'Ghế Imax', 0),
(1489, 'D2', 68, 4, 'Ghế Imax', 0),
(1490, 'D3', 68, 4, 'Ghế Imax', 0),
(1491, 'D4', 68, 4, 'Ghế Imax', 0),
(1492, 'D5', 68, 4, 'Ghế Imax', 0),
(1493, 'D6', 68, 4, 'Ghế Imax', 0),
(1494, 'D7', 68, 4, 'Ghế Imax', 0),
(1495, 'D8', 68, 4, 'Ghế Imax', 0),
(1496, 'D9', 68, 4, 'Ghế Imax', 0),
(1497, 'D10', 68, 4, 'Ghế Imax', 0),
(1498, 'D11', 68, 4, 'Ghế Imax', 0),
(1499, 'D12', 68, 4, 'Ghế Imax', 0),
(1500, 'E1', 68, 4, 'Ghế Imax', 0),
(1501, 'E2', 68, 4, 'Ghế Imax', 0),
(1502, 'E3', 68, 4, 'Ghế Imax', 0),
(1503, 'E4', 68, 4, 'Ghế Imax', 0),
(1504, 'E5', 68, 4, 'Ghế Imax', 0),
(1505, 'E6', 68, 4, 'Ghế Imax', 1),
(1506, 'E7', 68, 4, 'Ghế Imax', 0),
(1507, 'E8', 68, 4, 'Ghế Imax', 0),
(1508, 'E9', 68, 4, 'Ghế Imax', 0),
(1509, 'E10', 68, 4, 'Ghế Imax', 0),
(1510, 'E11', 68, 4, 'Ghế Imax', 0),
(1511, 'E12', 68, 4, 'Ghế Imax', 0),
(1512, 'F1', 68, 4, 'Ghế Imax', 0),
(1513, 'F2', 68, 4, 'Ghế Imax', 0),
(1514, 'F3', 68, 4, 'Ghế Imax', 0),
(1515, 'F4', 68, 4, 'Ghế Imax', 0),
(1516, 'F5', 68, 4, 'Ghế Imax', 0),
(1517, 'F6', 68, 4, 'Ghế Imax', 0),
(1518, 'F7', 68, 4, 'Ghế Imax', 0),
(1519, 'F8', 68, 4, 'Ghế Imax', 0),
(1520, 'F9', 68, 4, 'Ghế Imax', 0),
(1521, 'F10', 68, 4, 'Ghế Imax', 0),
(1522, 'F11', 68, 4, 'Ghế Imax', 0),
(1523, 'F12', 68, 4, 'Ghế Imax', 0),
(1524, 'G1', 68, 4, 'Ghế Imax', 0),
(1525, 'G2', 68, 4, 'Ghế Imax', 0),
(1526, 'G3', 68, 4, 'Ghế Imax', 0),
(1527, 'G4', 68, 4, 'Ghế Imax', 0),
(1528, 'G5', 68, 4, 'Ghế Imax', 0),
(1529, 'G6', 68, 4, 'Ghế Imax', 0),
(1530, 'G7', 68, 4, 'Ghế Imax', 0),
(1531, 'G8', 68, 4, 'Ghế Imax', 0),
(1532, 'G9', 68, 4, 'Ghế Imax', 0),
(1533, 'G10', 68, 4, 'Ghế Imax', 0),
(1534, 'G11', 68, 4, 'Ghế Imax', 0),
(1535, 'G12', 68, 4, 'Ghế Imax', 0),
(1536, 'H1', 68, 4, 'Ghế Imax', 0),
(1537, 'H2', 68, 4, 'Ghế Imax', 0),
(1538, 'H3', 68, 4, 'Ghế Imax', 0),
(1539, 'H4', 68, 4, 'Ghế Imax', 0),
(1540, 'H5', 68, 4, 'Ghế Imax', 0),
(1541, 'H6', 68, 4, 'Ghế Imax', 0),
(1542, 'H7', 68, 4, 'Ghế Imax', 0),
(1543, 'H8', 68, 4, 'Ghế Imax', 0),
(1544, 'H9', 68, 4, 'Ghế Imax', 0),
(1545, 'H10', 68, 4, 'Ghế Imax', 0),
(1546, 'H11', 68, 4, 'Ghế Imax', 0),
(1547, 'H12', 68, 4, 'Ghế Imax', 0),
(1548, 'I1', 68, 4, 'Ghế Imax', 0),
(1549, 'I2', 68, 4, 'Ghế Imax', 0),
(1550, 'I3', 68, 4, 'Ghế Imax', 0),
(1551, 'I4', 68, 4, 'Ghế Imax', 0),
(1552, 'I5', 68, 4, 'Ghế Imax', 0),
(1553, 'I6', 68, 4, 'Ghế Imax', 0),
(1554, 'I7', 68, 4, 'Ghế Imax', 0),
(1555, 'I8', 68, 4, 'Ghế Imax', 0),
(1556, 'I9', 68, 4, 'Ghế Imax', 0),
(1557, 'I10', 68, 4, 'Ghế Imax', 0),
(1558, 'I11', 68, 4, 'Ghế Imax', 0),
(1559, 'I12', 68, 4, 'Ghế Imax', 0),
(1560, 'J1', 68, 4, 'Ghế Imax', 0),
(1561, 'J2', 68, 4, 'Ghế Imax', 0),
(1562, 'J3', 68, 4, 'Ghế Imax', 0),
(1563, 'J4', 68, 4, 'Ghế Imax', 0),
(1564, 'J5', 68, 4, 'Ghế Imax', 0),
(1565, 'J6', 68, 4, 'Ghế Imax', 0),
(1566, 'J7', 68, 4, 'Ghế Imax', 0),
(1567, 'J8', 68, 4, 'Ghế Imax', 0),
(1568, 'J9', 68, 4, 'Ghế Imax', 0),
(1569, 'J10', 68, 4, 'Ghế Imax', 0),
(1570, 'J11', 68, 4, 'Ghế Imax', 0),
(1571, 'J12', 68, 4, 'Ghế Imax', 0),
(1572, 'A1', 69, 4, 'Ghế Thường', 0),
(1573, 'A2', 69, 4, 'Ghế Thường', 0),
(1574, 'A3', 69, 4, 'Ghế Thường', 0),
(1575, 'A4', 69, 4, 'Ghế Thường', 0),
(1576, 'A5', 69, 4, 'Ghế Thường', 0),
(1577, 'A6', 69, 4, 'Ghế Thường', 0);
INSERT INTO `ghe_ngoi` (`maghe`, `soghe`, `maphong`, `marap`, `tenloai`, `tinhtrang`) VALUES
(1578, 'A7', 69, 4, 'Ghế Thường', 0),
(1579, 'A8', 69, 4, 'Ghế Thường', 0),
(1580, 'A9', 69, 4, 'Ghế Thường', 0),
(1581, 'A10', 69, 4, 'Ghế Thường', 0),
(1582, 'A11', 69, 4, 'Ghế Thường', 0),
(1583, 'A12', 69, 4, 'Ghế Thường', 0),
(1584, 'B1', 69, 4, 'Ghế Thường', 0),
(1585, 'B2', 69, 4, 'Ghế Thường', 0),
(1586, 'B3', 69, 4, 'Ghế Thường', 0),
(1587, 'B4', 69, 4, 'Ghế Thường', 0),
(1588, 'B5', 69, 4, 'Ghế Thường', 0),
(1589, 'B6', 69, 4, 'Ghế Thường', 0),
(1590, 'B7', 69, 4, 'Ghế Thường', 0),
(1591, 'B8', 69, 4, 'Ghế Thường', 0),
(1592, 'B9', 69, 4, 'Ghế Thường', 0),
(1593, 'B10', 69, 4, 'Ghế Thường', 0),
(1594, 'B11', 69, 4, 'Ghế Thường', 0),
(1595, 'B12', 69, 4, 'Ghế Thường', 0),
(1596, 'C1', 69, 4, 'Ghế Thường', 0),
(1597, 'C2', 69, 4, 'Ghế Thường', 0),
(1598, 'C3', 69, 4, 'Ghế Thường', 0),
(1599, 'C4', 69, 4, 'Ghế Thường', 0),
(1600, 'C5', 69, 4, 'Ghế Thường', 0),
(1601, 'C6', 69, 4, 'Ghế Thường', 0),
(1602, 'C7', 69, 4, 'Ghế Thường', 0),
(1603, 'C8', 69, 4, 'Ghế Thường', 0),
(1604, 'C9', 69, 4, 'Ghế Thường', 0),
(1605, 'C10', 69, 4, 'Ghế Thường', 0),
(1606, 'C11', 69, 4, 'Ghế Thường', 0),
(1607, 'C12', 69, 4, 'Ghế Thường', 0),
(1608, 'D1', 69, 4, 'Ghế Thường', 0),
(1609, 'D2', 69, 4, 'Ghế Thường', 0),
(1610, 'D3', 69, 4, 'Ghế Thường', 0),
(1611, 'D4', 69, 4, 'Ghế Thường', 0),
(1612, 'D5', 69, 4, 'Ghế Thường', 0),
(1613, 'D6', 69, 4, 'Ghế Thường', 0),
(1614, 'D7', 69, 4, 'Ghế Thường', 0),
(1615, 'D8', 69, 4, 'Ghế Thường', 0),
(1616, 'D9', 69, 4, 'Ghế Thường', 0),
(1617, 'D10', 69, 4, 'Ghế Thường', 0),
(1618, 'D11', 69, 4, 'Ghế Thường', 0),
(1619, 'D12', 69, 4, 'Ghế Thường', 0),
(1620, 'E1', 69, 4, 'Ghế Thường', 0),
(1621, 'E2', 69, 4, 'Ghế Thường', 0),
(1622, 'E3', 69, 4, 'Ghế Thường', 0),
(1623, 'E4', 69, 4, 'Ghế Thường', 0),
(1624, 'E5', 69, 4, 'Ghế Thường', 0),
(1625, 'E6', 69, 4, 'Ghế Thường', 0),
(1626, 'E7', 69, 4, 'Ghế Thường', 0),
(1627, 'E8', 69, 4, 'Ghế Thường', 0),
(1628, 'E9', 69, 4, 'Ghế Thường', 0),
(1629, 'E10', 69, 4, 'Ghế Thường', 0),
(1630, 'E11', 69, 4, 'Ghế Thường', 0),
(1631, 'E12', 69, 4, 'Ghế Thường', 0),
(1632, 'F1', 69, 4, 'Ghế Thường', 0),
(1633, 'F2', 69, 4, 'Ghế Thường', 0),
(1634, 'F3', 69, 4, 'Ghế Thường', 0),
(1635, 'F4', 69, 4, 'Ghế Thường', 0),
(1636, 'F5', 69, 4, 'Ghế Thường', 0),
(1637, 'F6', 69, 4, 'Ghế Thường', 0),
(1638, 'F7', 69, 4, 'Ghế Thường', 0),
(1639, 'F8', 69, 4, 'Ghế Thường', 0),
(1640, 'F9', 69, 4, 'Ghế Thường', 0),
(1641, 'F10', 69, 4, 'Ghế Thường', 0),
(1642, 'F11', 69, 4, 'Ghế Thường', 0),
(1643, 'F12', 69, 4, 'Ghế Thường', 0),
(1644, 'G1', 69, 4, 'Ghế Thường', 0),
(1645, 'G2', 69, 4, 'Ghế Thường', 0),
(1646, 'G3', 69, 4, 'Ghế Thường', 0),
(1647, 'G4', 69, 4, 'Ghế Thường', 0),
(1648, 'G5', 69, 4, 'Ghế Thường', 0),
(1649, 'G6', 69, 4, 'Ghế Thường', 0),
(1650, 'G7', 69, 4, 'Ghế Thường', 0),
(1651, 'G8', 69, 4, 'Ghế Thường', 0),
(1652, 'G9', 69, 4, 'Ghế Thường', 0),
(1653, 'G10', 69, 4, 'Ghế Thường', 0),
(1654, 'G11', 69, 4, 'Ghế Thường', 0),
(1655, 'G12', 69, 4, 'Ghế Thường', 0),
(1656, 'H1', 69, 4, 'Ghế Thường', 0),
(1657, 'H2', 69, 4, 'Ghế Thường', 0),
(1658, 'H3', 69, 4, 'Ghế Thường', 0),
(1659, 'H4', 69, 4, 'Ghế Thường', 0),
(1660, 'H5', 69, 4, 'Ghế Thường', 0),
(1661, 'H6', 69, 4, 'Ghế Thường', 0),
(1662, 'H7', 69, 4, 'Ghế Thường', 0),
(1663, 'H8', 69, 4, 'Ghế Thường', 0),
(1664, 'H9', 69, 4, 'Ghế Thường', 0),
(1665, 'H10', 69, 4, 'Ghế Thường', 0),
(1666, 'H11', 69, 4, 'Ghế Thường', 0),
(1667, 'H12', 69, 4, 'Ghế Thường', 0),
(1668, 'I1', 69, 4, 'Ghế Thường', 0),
(1669, 'I2', 69, 4, 'Ghế Thường', 0),
(1670, 'I3', 69, 4, 'Ghế Thường', 0),
(1671, 'I4', 69, 4, 'Ghế Thường', 0),
(1672, 'I5', 69, 4, 'Ghế Thường', 0),
(1673, 'I6', 69, 4, 'Ghế Thường', 0),
(1674, 'I7', 69, 4, 'Ghế Thường', 0),
(1675, 'I8', 69, 4, 'Ghế Thường', 0),
(1676, 'I9', 69, 4, 'Ghế Thường', 0),
(1677, 'I10', 69, 4, 'Ghế Thường', 0),
(1678, 'I11', 69, 4, 'Ghế Thường', 0),
(1679, 'I12', 69, 4, 'Ghế Thường', 0),
(1680, 'J1', 69, 4, 'Ghế đôi', 0),
(1681, 'J2', 69, 4, 'Ghế đôi', 0),
(1682, 'J3', 69, 4, 'Ghế đôi', 0),
(1683, 'J4', 69, 4, 'Ghế đôi', 0),
(1684, 'J5', 69, 4, 'Ghế đôi', 0),
(1685, 'J6', 69, 4, 'Ghế đôi', 0),
(1686, 'J7', 69, 4, 'Ghế đôi', 0),
(1687, 'J8', 69, 4, 'Ghế đôi', 0),
(1688, 'J9', 69, 4, 'Ghế đôi', 0),
(1689, 'J10', 69, 4, 'Ghế đôi', 0),
(1690, 'J11', 69, 4, 'Ghế đôi', 0),
(1691, 'J12', 69, 4, 'Ghế đôi', 0),
(1692, 'A1', 70, 5, 'Ghế Thường', 0),
(1693, 'A2', 70, 5, 'Ghế Thường', 0),
(1694, 'A3', 70, 5, 'Ghế Thường', 0),
(1695, 'A4', 70, 5, 'Ghế Thường', 0),
(1696, 'A5', 70, 5, 'Ghế Thường', 0),
(1697, 'A6', 70, 5, 'Ghế Thường', 0),
(1698, 'A7', 70, 5, 'Ghế Thường', 0),
(1699, 'A8', 70, 5, 'Ghế Thường', 0),
(1700, 'A9', 70, 5, 'Ghế Thường', 0),
(1701, 'A10', 70, 5, 'Ghế Thường', 0),
(1702, 'A11', 70, 5, 'Ghế Thường', 0),
(1703, 'A12', 70, 5, 'Ghế Thường', 0),
(1704, 'B1', 70, 5, 'Ghế Thường', 0),
(1705, 'B2', 70, 5, 'Ghế Thường', 0),
(1706, 'B3', 70, 5, 'Ghế Thường', 0),
(1707, 'B4', 70, 5, 'Ghế Thường', 0),
(1708, 'B5', 70, 5, 'Ghế Thường', 0),
(1709, 'B6', 70, 5, 'Ghế Thường', 0),
(1710, 'B7', 70, 5, 'Ghế Thường', 0),
(1711, 'B8', 70, 5, 'Ghế Thường', 0),
(1712, 'B9', 70, 5, 'Ghế Thường', 0),
(1713, 'B10', 70, 5, 'Ghế Thường', 0),
(1714, 'B11', 70, 5, 'Ghế Thường', 0),
(1715, 'B12', 70, 5, 'Ghế Thường', 0),
(1716, 'C1', 70, 5, 'Ghế Thường', 0),
(1717, 'C2', 70, 5, 'Ghế Thường', 0),
(1718, 'C3', 70, 5, 'Ghế Thường', 0),
(1719, 'C4', 70, 5, 'Ghế Thường', 0),
(1720, 'C5', 70, 5, 'Ghế Thường', 0),
(1721, 'C6', 70, 5, 'Ghế Thường', 0),
(1722, 'C7', 70, 5, 'Ghế Thường', 0),
(1723, 'C8', 70, 5, 'Ghế Thường', 0),
(1724, 'C9', 70, 5, 'Ghế Thường', 0),
(1725, 'C10', 70, 5, 'Ghế Thường', 0),
(1726, 'C11', 70, 5, 'Ghế Thường', 0),
(1727, 'C12', 70, 5, 'Ghế Thường', 0),
(1728, 'D1', 70, 5, 'Ghế Thường', 0),
(1729, 'D2', 70, 5, 'Ghế Thường', 0),
(1730, 'D3', 70, 5, 'Ghế Thường', 0),
(1731, 'D4', 70, 5, 'Ghế Thường', 0),
(1732, 'D5', 70, 5, 'Ghế Thường', 0),
(1733, 'D6', 70, 5, 'Ghế Thường', 0),
(1734, 'D7', 70, 5, 'Ghế Thường', 0),
(1735, 'D8', 70, 5, 'Ghế Thường', 0),
(1736, 'D9', 70, 5, 'Ghế Thường', 0),
(1737, 'D10', 70, 5, 'Ghế Thường', 0),
(1738, 'D11', 70, 5, 'Ghế Thường', 0),
(1739, 'D12', 70, 5, 'Ghế Thường', 0),
(1740, 'E1', 70, 5, 'Ghế Thường', 0),
(1741, 'E2', 70, 5, 'Ghế Thường', 0),
(1742, 'E3', 70, 5, 'Ghế Thường', 0),
(1743, 'E4', 70, 5, 'Ghế Thường', 0),
(1744, 'E5', 70, 5, 'Ghế Thường', 1),
(1745, 'E6', 70, 5, 'Ghế Thường', 1),
(1746, 'E7', 70, 5, 'Ghế Thường', 0),
(1747, 'E8', 70, 5, 'Ghế Thường', 0),
(1748, 'E9', 70, 5, 'Ghế Thường', 0),
(1749, 'E10', 70, 5, 'Ghế Thường', 0),
(1750, 'E11', 70, 5, 'Ghế Thường', 0),
(1751, 'E12', 70, 5, 'Ghế Thường', 0),
(1752, 'F1', 70, 5, 'Ghế Thường', 0),
(1753, 'F2', 70, 5, 'Ghế Thường', 0),
(1754, 'F3', 70, 5, 'Ghế Thường', 0),
(1755, 'F4', 70, 5, 'Ghế Thường', 0),
(1756, 'F5', 70, 5, 'Ghế Thường', 0),
(1757, 'F6', 70, 5, 'Ghế Thường', 0),
(1758, 'F7', 70, 5, 'Ghế Thường', 0),
(1759, 'F8', 70, 5, 'Ghế Thường', 0),
(1760, 'F9', 70, 5, 'Ghế Thường', 0),
(1761, 'F10', 70, 5, 'Ghế Thường', 0),
(1762, 'F11', 70, 5, 'Ghế Thường', 0),
(1763, 'F12', 70, 5, 'Ghế Thường', 0),
(1764, 'G1', 70, 5, 'Ghế Thường', 0),
(1765, 'G2', 70, 5, 'Ghế Thường', 0),
(1766, 'G3', 70, 5, 'Ghế Thường', 0),
(1767, 'G4', 70, 5, 'Ghế Thường', 0),
(1768, 'G5', 70, 5, 'Ghế Thường', 0),
(1769, 'G6', 70, 5, 'Ghế Thường', 0),
(1770, 'G7', 70, 5, 'Ghế Thường', 0),
(1771, 'G8', 70, 5, 'Ghế Thường', 0),
(1772, 'G9', 70, 5, 'Ghế Thường', 0),
(1773, 'G10', 70, 5, 'Ghế Thường', 0),
(1774, 'G11', 70, 5, 'Ghế Thường', 0),
(1775, 'G12', 70, 5, 'Ghế Thường', 0),
(1776, 'H1', 70, 5, 'Ghế Thường', 0),
(1777, 'H2', 70, 5, 'Ghế Thường', 0),
(1778, 'H3', 70, 5, 'Ghế Thường', 0),
(1779, 'H4', 70, 5, 'Ghế Thường', 0),
(1780, 'H5', 70, 5, 'Ghế Thường', 0),
(1781, 'H6', 70, 5, 'Ghế Thường', 0),
(1782, 'H7', 70, 5, 'Ghế Thường', 0),
(1783, 'H8', 70, 5, 'Ghế Thường', 0),
(1784, 'H9', 70, 5, 'Ghế Thường', 0),
(1785, 'H10', 70, 5, 'Ghế Thường', 0),
(1786, 'H11', 70, 5, 'Ghế Thường', 0),
(1787, 'H12', 70, 5, 'Ghế Thường', 0),
(1788, 'I1', 70, 5, 'Ghế Thường', 0),
(1789, 'I2', 70, 5, 'Ghế Thường', 0),
(1790, 'I3', 70, 5, 'Ghế Thường', 0),
(1791, 'I4', 70, 5, 'Ghế Thường', 0),
(1792, 'I5', 70, 5, 'Ghế Thường', 0),
(1793, 'I6', 70, 5, 'Ghế Thường', 0),
(1794, 'I7', 70, 5, 'Ghế Thường', 0),
(1795, 'I8', 70, 5, 'Ghế Thường', 0),
(1796, 'I9', 70, 5, 'Ghế Thường', 0),
(1797, 'I10', 70, 5, 'Ghế Thường', 0),
(1798, 'I11', 70, 5, 'Ghế Thường', 0),
(1799, 'I12', 70, 5, 'Ghế Thường', 0),
(1800, 'J1', 70, 5, 'Ghế đôi', 0),
(1801, 'J2', 70, 5, 'Ghế đôi', 0),
(1802, 'J3', 70, 5, 'Ghế đôi', 0),
(1803, 'J4', 70, 5, 'Ghế đôi', 0),
(1804, 'J5', 70, 5, 'Ghế đôi', 0),
(1805, 'J6', 70, 5, 'Ghế đôi', 0),
(1806, 'J7', 70, 5, 'Ghế đôi', 0),
(1807, 'J8', 70, 5, 'Ghế đôi', 0),
(1808, 'J9', 70, 5, 'Ghế đôi', 0),
(1809, 'J10', 70, 5, 'Ghế đôi', 0),
(1810, 'J11', 70, 5, 'Ghế đôi', 0),
(1811, 'J12', 70, 5, 'Ghế đôi', 0),
(1812, 'A1', 71, 5, 'Gold Class', 0),
(1813, 'A2', 71, 5, 'Gold Class', 0),
(1814, 'A3', 71, 5, 'Gold Class', 0),
(1815, 'A4', 71, 5, 'Gold Class', 0),
(1816, 'A5', 71, 5, 'Gold Class', 0),
(1817, 'A6', 71, 5, 'Gold Class', 0),
(1818, 'A7', 71, 5, 'Gold Class', 0),
(1819, 'A8', 71, 5, 'Gold Class', 0),
(1820, 'A9', 71, 5, 'Gold Class', 0),
(1821, 'A10', 71, 5, 'Gold Class', 0),
(1822, 'A11', 71, 5, 'Gold Class', 0),
(1823, 'A12', 71, 5, 'Gold Class', 0),
(1824, 'B1', 71, 5, 'Gold Class', 0),
(1825, 'B2', 71, 5, 'Gold Class', 0),
(1826, 'B3', 71, 5, 'Gold Class', 0),
(1827, 'B4', 71, 5, 'Gold Class', 0),
(1828, 'B5', 71, 5, 'Gold Class', 0),
(1829, 'B6', 71, 5, 'Gold Class', 0),
(1830, 'B7', 71, 5, 'Gold Class', 0),
(1831, 'B8', 71, 5, 'Gold Class', 0),
(1832, 'B9', 71, 5, 'Gold Class', 0),
(1833, 'B10', 71, 5, 'Gold Class', 0),
(1834, 'B11', 71, 5, 'Gold Class', 0),
(1835, 'B12', 71, 5, 'Gold Class', 0),
(1836, 'C1', 71, 5, 'Gold Class', 0),
(1837, 'C2', 71, 5, 'Gold Class', 0),
(1838, 'C3', 71, 5, 'Gold Class', 0),
(1839, 'C4', 71, 5, 'Gold Class', 0),
(1840, 'C5', 71, 5, 'Gold Class', 0),
(1841, 'C6', 71, 5, 'Gold Class', 0),
(1842, 'C7', 71, 5, 'Gold Class', 0),
(1843, 'C8', 71, 5, 'Gold Class', 0),
(1844, 'C9', 71, 5, 'Gold Class', 0),
(1845, 'C10', 71, 5, 'Gold Class', 0),
(1846, 'C11', 71, 5, 'Gold Class', 0),
(1847, 'C12', 71, 5, 'Gold Class', 0),
(1848, 'D1', 71, 5, 'Gold Class', 0),
(1849, 'D2', 71, 5, 'Gold Class', 0),
(1850, 'D3', 71, 5, 'Gold Class', 0),
(1851, 'D4', 71, 5, 'Gold Class', 0),
(1852, 'D5', 71, 5, 'Gold Class', 0),
(1853, 'D6', 71, 5, 'Gold Class', 0),
(1854, 'D7', 71, 5, 'Gold Class', 0),
(1855, 'D8', 71, 5, 'Gold Class', 0),
(1856, 'D9', 71, 5, 'Gold Class', 0),
(1857, 'D10', 71, 5, 'Gold Class', 0),
(1858, 'D11', 71, 5, 'Gold Class', 0),
(1859, 'D12', 71, 5, 'Gold Class', 0),
(1860, 'E1', 71, 5, 'Gold Class', 0),
(1861, 'E2', 71, 5, 'Gold Class', 0),
(1862, 'E3', 71, 5, 'Gold Class', 0),
(1863, 'E4', 71, 5, 'Gold Class', 0),
(1864, 'E5', 71, 5, 'Gold Class', 0),
(1865, 'E6', 71, 5, 'Gold Class', 0),
(1866, 'E7', 71, 5, 'Gold Class', 0),
(1867, 'E8', 71, 5, 'Gold Class', 0),
(1868, 'E9', 71, 5, 'Gold Class', 0),
(1869, 'E10', 71, 5, 'Gold Class', 0),
(1870, 'E11', 71, 5, 'Gold Class', 0),
(1871, 'E12', 71, 5, 'Gold Class', 0),
(1872, 'F1', 71, 5, 'Gold Class', 0),
(1873, 'F2', 71, 5, 'Gold Class', 0),
(1874, 'F3', 71, 5, 'Gold Class', 0),
(1875, 'F4', 71, 5, 'Gold Class', 0),
(1876, 'F5', 71, 5, 'Gold Class', 0),
(1877, 'F6', 71, 5, 'Gold Class', 0),
(1878, 'F7', 71, 5, 'Gold Class', 0),
(1879, 'F8', 71, 5, 'Gold Class', 0),
(1880, 'F9', 71, 5, 'Gold Class', 0),
(1881, 'F10', 71, 5, 'Gold Class', 0),
(1882, 'F11', 71, 5, 'Gold Class', 0),
(1883, 'F12', 71, 5, 'Gold Class', 0),
(1884, 'G1', 71, 5, 'Gold Class', 0),
(1885, 'G2', 71, 5, 'Gold Class', 0),
(1886, 'G3', 71, 5, 'Gold Class', 0),
(1887, 'G4', 71, 5, 'Gold Class', 0),
(1888, 'G5', 71, 5, 'Gold Class', 0),
(1889, 'G6', 71, 5, 'Gold Class', 0),
(1890, 'G7', 71, 5, 'Gold Class', 0),
(1891, 'G8', 71, 5, 'Gold Class', 0),
(1892, 'G9', 71, 5, 'Gold Class', 0),
(1893, 'G10', 71, 5, 'Gold Class', 0),
(1894, 'G11', 71, 5, 'Gold Class', 0),
(1895, 'G12', 71, 5, 'Gold Class', 0),
(1896, 'H1', 71, 5, 'Gold Class', 0),
(1897, 'H2', 71, 5, 'Gold Class', 0),
(1898, 'H3', 71, 5, 'Gold Class', 0),
(1899, 'H4', 71, 5, 'Gold Class', 0),
(1900, 'H5', 71, 5, 'Gold Class', 0),
(1901, 'H6', 71, 5, 'Gold Class', 0),
(1902, 'H7', 71, 5, 'Gold Class', 0),
(1903, 'H8', 71, 5, 'Gold Class', 0),
(1904, 'H9', 71, 5, 'Gold Class', 0),
(1905, 'H10', 71, 5, 'Gold Class', 0),
(1906, 'H11', 71, 5, 'Gold Class', 0),
(1907, 'H12', 71, 5, 'Gold Class', 0),
(1908, 'I1', 71, 5, 'Gold Class', 0),
(1909, 'I2', 71, 5, 'Gold Class', 0),
(1910, 'I3', 71, 5, 'Gold Class', 0),
(1911, 'I4', 71, 5, 'Gold Class', 0),
(1912, 'I5', 71, 5, 'Gold Class', 0),
(1913, 'I6', 71, 5, 'Gold Class', 0),
(1914, 'I7', 71, 5, 'Gold Class', 0),
(1915, 'I8', 71, 5, 'Gold Class', 0),
(1916, 'I9', 71, 5, 'Gold Class', 0),
(1917, 'I10', 71, 5, 'Gold Class', 0),
(1918, 'I11', 71, 5, 'Gold Class', 0),
(1919, 'I12', 71, 5, 'Gold Class', 0),
(1920, 'J1', 71, 5, 'Gold Class', 0),
(1921, 'J2', 71, 5, 'Gold Class', 0),
(1922, 'J3', 71, 5, 'Gold Class', 0),
(1923, 'J4', 71, 5, 'Gold Class', 0),
(1924, 'J5', 71, 5, 'Gold Class', 0),
(1925, 'J6', 71, 5, 'Gold Class', 0),
(1926, 'J7', 71, 5, 'Gold Class', 0),
(1927, 'J8', 71, 5, 'Gold Class', 0),
(1928, 'J9', 71, 5, 'Gold Class', 0),
(1929, 'J10', 71, 5, 'Gold Class', 0),
(1930, 'J11', 71, 5, 'Gold Class', 0),
(1931, 'J12', 71, 5, 'Gold Class', 0),
(1932, 'A1', 72, 5, 'Ghế 4DX', 0),
(1933, 'A2', 72, 5, 'Ghế 4DX', 0),
(1934, 'A3', 72, 5, 'Ghế 4DX', 0),
(1935, 'A4', 72, 5, 'Ghế 4DX', 0),
(1936, 'A5', 72, 5, 'Ghế 4DX', 0),
(1937, 'A6', 72, 5, 'Ghế 4DX', 0),
(1938, 'A7', 72, 5, 'Ghế 4DX', 0),
(1939, 'A8', 72, 5, 'Ghế 4DX', 0),
(1940, 'A9', 72, 5, 'Ghế 4DX', 0),
(1941, 'A10', 72, 5, 'Ghế 4DX', 0),
(1942, 'A11', 72, 5, 'Ghế 4DX', 0),
(1943, 'A12', 72, 5, 'Ghế 4DX', 0),
(1944, 'B1', 72, 5, 'Ghế 4DX', 0),
(1945, 'B2', 72, 5, 'Ghế 4DX', 0),
(1946, 'B3', 72, 5, 'Ghế 4DX', 0),
(1947, 'B4', 72, 5, 'Ghế 4DX', 0),
(1948, 'B5', 72, 5, 'Ghế 4DX', 0),
(1949, 'B6', 72, 5, 'Ghế 4DX', 0),
(1950, 'B7', 72, 5, 'Ghế 4DX', 0),
(1951, 'B8', 72, 5, 'Ghế 4DX', 0),
(1952, 'B9', 72, 5, 'Ghế 4DX', 0),
(1953, 'B10', 72, 5, 'Ghế 4DX', 0),
(1954, 'B11', 72, 5, 'Ghế 4DX', 0),
(1955, 'B12', 72, 5, 'Ghế 4DX', 0),
(1956, 'C1', 72, 5, 'Ghế 4DX', 0),
(1957, 'C2', 72, 5, 'Ghế 4DX', 0),
(1958, 'C3', 72, 5, 'Ghế 4DX', 0),
(1959, 'C4', 72, 5, 'Ghế 4DX', 0),
(1960, 'C5', 72, 5, 'Ghế 4DX', 0),
(1961, 'C6', 72, 5, 'Ghế 4DX', 0),
(1962, 'C7', 72, 5, 'Ghế 4DX', 0),
(1963, 'C8', 72, 5, 'Ghế 4DX', 0),
(1964, 'C9', 72, 5, 'Ghế 4DX', 0),
(1965, 'C10', 72, 5, 'Ghế 4DX', 0),
(1966, 'C11', 72, 5, 'Ghế 4DX', 0),
(1967, 'C12', 72, 5, 'Ghế 4DX', 0),
(1968, 'D1', 72, 5, 'Ghế 4DX', 0),
(1969, 'D2', 72, 5, 'Ghế 4DX', 0),
(1970, 'D3', 72, 5, 'Ghế 4DX', 0),
(1971, 'D4', 72, 5, 'Ghế 4DX', 0),
(1972, 'D5', 72, 5, 'Ghế 4DX', 0),
(1973, 'D6', 72, 5, 'Ghế 4DX', 0),
(1974, 'D7', 72, 5, 'Ghế 4DX', 0),
(1975, 'D8', 72, 5, 'Ghế 4DX', 0),
(1976, 'D9', 72, 5, 'Ghế 4DX', 0),
(1977, 'D10', 72, 5, 'Ghế 4DX', 0),
(1978, 'D11', 72, 5, 'Ghế 4DX', 0),
(1979, 'D12', 72, 5, 'Ghế 4DX', 0),
(1980, 'E1', 72, 5, 'Ghế 4DX', 0),
(1981, 'E2', 72, 5, 'Ghế 4DX', 0),
(1982, 'E3', 72, 5, 'Ghế 4DX', 0),
(1983, 'E4', 72, 5, 'Ghế 4DX', 0),
(1984, 'E5', 72, 5, 'Ghế 4DX', 0),
(1985, 'E6', 72, 5, 'Ghế 4DX', 0),
(1986, 'E7', 72, 5, 'Ghế 4DX', 0),
(1987, 'E8', 72, 5, 'Ghế 4DX', 0),
(1988, 'E9', 72, 5, 'Ghế 4DX', 0),
(1989, 'E10', 72, 5, 'Ghế 4DX', 0),
(1990, 'E11', 72, 5, 'Ghế 4DX', 0),
(1991, 'E12', 72, 5, 'Ghế 4DX', 0),
(1992, 'F1', 72, 5, 'Ghế 4DX', 0),
(1993, 'F2', 72, 5, 'Ghế 4DX', 0),
(1994, 'F3', 72, 5, 'Ghế 4DX', 0),
(1995, 'F4', 72, 5, 'Ghế 4DX', 0),
(1996, 'F5', 72, 5, 'Ghế 4DX', 0),
(1997, 'F6', 72, 5, 'Ghế 4DX', 0),
(1998, 'F7', 72, 5, 'Ghế 4DX', 0),
(1999, 'F8', 72, 5, 'Ghế 4DX', 0),
(2000, 'F9', 72, 5, 'Ghế 4DX', 0),
(2001, 'F10', 72, 5, 'Ghế 4DX', 0),
(2002, 'F11', 72, 5, 'Ghế 4DX', 0),
(2003, 'F12', 72, 5, 'Ghế 4DX', 0),
(2004, 'G1', 72, 5, 'Ghế 4DX', 0),
(2005, 'G2', 72, 5, 'Ghế 4DX', 0),
(2006, 'G3', 72, 5, 'Ghế 4DX', 0),
(2007, 'G4', 72, 5, 'Ghế 4DX', 0),
(2008, 'G5', 72, 5, 'Ghế 4DX', 0),
(2009, 'G6', 72, 5, 'Ghế 4DX', 0),
(2010, 'G7', 72, 5, 'Ghế 4DX', 0),
(2011, 'G8', 72, 5, 'Ghế 4DX', 0),
(2012, 'G9', 72, 5, 'Ghế 4DX', 0),
(2013, 'G10', 72, 5, 'Ghế 4DX', 0),
(2014, 'G11', 72, 5, 'Ghế 4DX', 0),
(2015, 'G12', 72, 5, 'Ghế 4DX', 0),
(2016, 'H1', 72, 5, 'Ghế 4DX', 0),
(2017, 'H2', 72, 5, 'Ghế 4DX', 0),
(2018, 'H3', 72, 5, 'Ghế 4DX', 0),
(2019, 'H4', 72, 5, 'Ghế 4DX', 0),
(2020, 'H5', 72, 5, 'Ghế 4DX', 0),
(2021, 'H6', 72, 5, 'Ghế 4DX', 0),
(2022, 'H7', 72, 5, 'Ghế 4DX', 0),
(2023, 'H8', 72, 5, 'Ghế 4DX', 0),
(2024, 'H9', 72, 5, 'Ghế 4DX', 0),
(2025, 'H10', 72, 5, 'Ghế 4DX', 0),
(2026, 'H11', 72, 5, 'Ghế 4DX', 0),
(2027, 'H12', 72, 5, 'Ghế 4DX', 0),
(2028, 'I1', 72, 5, 'Ghế 4DX', 0),
(2029, 'I2', 72, 5, 'Ghế 4DX', 0),
(2030, 'I3', 72, 5, 'Ghế 4DX', 0),
(2031, 'I4', 72, 5, 'Ghế 4DX', 0),
(2032, 'I5', 72, 5, 'Ghế 4DX', 0),
(2033, 'I6', 72, 5, 'Ghế 4DX', 0),
(2034, 'I7', 72, 5, 'Ghế 4DX', 0),
(2035, 'I8', 72, 5, 'Ghế 4DX', 0),
(2036, 'I9', 72, 5, 'Ghế 4DX', 0),
(2037, 'I10', 72, 5, 'Ghế 4DX', 0),
(2038, 'I11', 72, 5, 'Ghế 4DX', 0),
(2039, 'I12', 72, 5, 'Ghế 4DX', 0),
(2040, 'J1', 72, 5, 'Ghế 4DX', 0),
(2041, 'J2', 72, 5, 'Ghế 4DX', 0),
(2042, 'J3', 72, 5, 'Ghế 4DX', 0),
(2043, 'J4', 72, 5, 'Ghế 4DX', 0),
(2044, 'J5', 72, 5, 'Ghế 4DX', 0),
(2045, 'J6', 72, 5, 'Ghế 4DX', 0),
(2046, 'J7', 72, 5, 'Ghế 4DX', 0),
(2047, 'J8', 72, 5, 'Ghế 4DX', 0),
(2048, 'J9', 72, 5, 'Ghế 4DX', 0),
(2049, 'J10', 72, 5, 'Ghế 4DX', 0),
(2050, 'J11', 72, 5, 'Ghế 4DX', 0),
(2051, 'J12', 72, 5, 'Ghế 4DX', 0),
(2052, 'A1', 73, 5, 'Ghế Imax', 0),
(2053, 'A2', 73, 5, 'Ghế Imax', 0),
(2054, 'A3', 73, 5, 'Ghế Imax', 0),
(2055, 'A4', 73, 5, 'Ghế Imax', 0),
(2056, 'A5', 73, 5, 'Ghế Imax', 0),
(2057, 'A6', 73, 5, 'Ghế Imax', 0),
(2058, 'A7', 73, 5, 'Ghế Imax', 0),
(2059, 'A8', 73, 5, 'Ghế Imax', 0),
(2060, 'A9', 73, 5, 'Ghế Imax', 0),
(2061, 'A10', 73, 5, 'Ghế Imax', 0),
(2062, 'A11', 73, 5, 'Ghế Imax', 0),
(2063, 'A12', 73, 5, 'Ghế Imax', 0),
(2064, 'B1', 73, 5, 'Ghế Imax', 0),
(2065, 'B2', 73, 5, 'Ghế Imax', 0),
(2066, 'B3', 73, 5, 'Ghế Imax', 0),
(2067, 'B4', 73, 5, 'Ghế Imax', 0),
(2068, 'B5', 73, 5, 'Ghế Imax', 0),
(2069, 'B6', 73, 5, 'Ghế Imax', 0),
(2070, 'B7', 73, 5, 'Ghế Imax', 0),
(2071, 'B8', 73, 5, 'Ghế Imax', 0),
(2072, 'B9', 73, 5, 'Ghế Imax', 0),
(2073, 'B10', 73, 5, 'Ghế Imax', 0),
(2074, 'B11', 73, 5, 'Ghế Imax', 0),
(2075, 'B12', 73, 5, 'Ghế Imax', 0),
(2076, 'C1', 73, 5, 'Ghế Imax', 0),
(2077, 'C2', 73, 5, 'Ghế Imax', 0),
(2078, 'C3', 73, 5, 'Ghế Imax', 0),
(2079, 'C4', 73, 5, 'Ghế Imax', 0),
(2080, 'C5', 73, 5, 'Ghế Imax', 0),
(2081, 'C6', 73, 5, 'Ghế Imax', 0),
(2082, 'C7', 73, 5, 'Ghế Imax', 0),
(2083, 'C8', 73, 5, 'Ghế Imax', 0),
(2084, 'C9', 73, 5, 'Ghế Imax', 0),
(2085, 'C10', 73, 5, 'Ghế Imax', 0),
(2086, 'C11', 73, 5, 'Ghế Imax', 0),
(2087, 'C12', 73, 5, 'Ghế Imax', 0),
(2088, 'D1', 73, 5, 'Ghế Imax', 0),
(2089, 'D2', 73, 5, 'Ghế Imax', 0),
(2090, 'D3', 73, 5, 'Ghế Imax', 0),
(2091, 'D4', 73, 5, 'Ghế Imax', 0),
(2092, 'D5', 73, 5, 'Ghế Imax', 0),
(2093, 'D6', 73, 5, 'Ghế Imax', 0),
(2094, 'D7', 73, 5, 'Ghế Imax', 0),
(2095, 'D8', 73, 5, 'Ghế Imax', 0),
(2096, 'D9', 73, 5, 'Ghế Imax', 0),
(2097, 'D10', 73, 5, 'Ghế Imax', 0),
(2098, 'D11', 73, 5, 'Ghế Imax', 0),
(2099, 'D12', 73, 5, 'Ghế Imax', 0),
(2100, 'E1', 73, 5, 'Ghế Imax', 0),
(2101, 'E2', 73, 5, 'Ghế Imax', 0),
(2102, 'E3', 73, 5, 'Ghế Imax', 0),
(2103, 'E4', 73, 5, 'Ghế Imax', 0),
(2104, 'E5', 73, 5, 'Ghế Imax', 0),
(2105, 'E6', 73, 5, 'Ghế Imax', 0),
(2106, 'E7', 73, 5, 'Ghế Imax', 0),
(2107, 'E8', 73, 5, 'Ghế Imax', 0),
(2108, 'E9', 73, 5, 'Ghế Imax', 0),
(2109, 'E10', 73, 5, 'Ghế Imax', 0),
(2110, 'E11', 73, 5, 'Ghế Imax', 0),
(2111, 'E12', 73, 5, 'Ghế Imax', 0),
(2112, 'F1', 73, 5, 'Ghế Imax', 0),
(2113, 'F2', 73, 5, 'Ghế Imax', 0),
(2114, 'F3', 73, 5, 'Ghế Imax', 0),
(2115, 'F4', 73, 5, 'Ghế Imax', 0),
(2116, 'F5', 73, 5, 'Ghế Imax', 0),
(2117, 'F6', 73, 5, 'Ghế Imax', 0),
(2118, 'F7', 73, 5, 'Ghế Imax', 0),
(2119, 'F8', 73, 5, 'Ghế Imax', 0),
(2120, 'F9', 73, 5, 'Ghế Imax', 0),
(2121, 'F10', 73, 5, 'Ghế Imax', 0),
(2122, 'F11', 73, 5, 'Ghế Imax', 0),
(2123, 'F12', 73, 5, 'Ghế Imax', 0),
(2124, 'G1', 73, 5, 'Ghế Imax', 0),
(2125, 'G2', 73, 5, 'Ghế Imax', 0),
(2126, 'G3', 73, 5, 'Ghế Imax', 0),
(2127, 'G4', 73, 5, 'Ghế Imax', 0),
(2128, 'G5', 73, 5, 'Ghế Imax', 0),
(2129, 'G6', 73, 5, 'Ghế Imax', 0),
(2130, 'G7', 73, 5, 'Ghế Imax', 0),
(2131, 'G8', 73, 5, 'Ghế Imax', 0),
(2132, 'G9', 73, 5, 'Ghế Imax', 0),
(2133, 'G10', 73, 5, 'Ghế Imax', 0),
(2134, 'G11', 73, 5, 'Ghế Imax', 0),
(2135, 'G12', 73, 5, 'Ghế Imax', 0),
(2136, 'H1', 73, 5, 'Ghế Imax', 0),
(2137, 'H2', 73, 5, 'Ghế Imax', 0),
(2138, 'H3', 73, 5, 'Ghế Imax', 0),
(2139, 'H4', 73, 5, 'Ghế Imax', 0),
(2140, 'H5', 73, 5, 'Ghế Imax', 0),
(2141, 'H6', 73, 5, 'Ghế Imax', 0),
(2142, 'H7', 73, 5, 'Ghế Imax', 0),
(2143, 'H8', 73, 5, 'Ghế Imax', 0),
(2144, 'H9', 73, 5, 'Ghế Imax', 0),
(2145, 'H10', 73, 5, 'Ghế Imax', 0),
(2146, 'H11', 73, 5, 'Ghế Imax', 0),
(2147, 'H12', 73, 5, 'Ghế Imax', 0),
(2148, 'I1', 73, 5, 'Ghế Imax', 0),
(2149, 'I2', 73, 5, 'Ghế Imax', 0),
(2150, 'I3', 73, 5, 'Ghế Imax', 0),
(2151, 'I4', 73, 5, 'Ghế Imax', 0),
(2152, 'I5', 73, 5, 'Ghế Imax', 0),
(2153, 'I6', 73, 5, 'Ghế Imax', 0),
(2154, 'I7', 73, 5, 'Ghế Imax', 0),
(2155, 'I8', 73, 5, 'Ghế Imax', 0),
(2156, 'I9', 73, 5, 'Ghế Imax', 0),
(2157, 'I10', 73, 5, 'Ghế Imax', 0),
(2158, 'I11', 73, 5, 'Ghế Imax', 0),
(2159, 'I12', 73, 5, 'Ghế Imax', 0),
(2160, 'J1', 73, 5, 'Ghế Imax', 0),
(2161, 'J2', 73, 5, 'Ghế Imax', 0),
(2162, 'J3', 73, 5, 'Ghế Imax', 0),
(2163, 'J4', 73, 5, 'Ghế Imax', 0),
(2164, 'J5', 73, 5, 'Ghế Imax', 0),
(2165, 'J6', 73, 5, 'Ghế Imax', 0),
(2166, 'J7', 73, 5, 'Ghế Imax', 0),
(2167, 'J8', 73, 5, 'Ghế Imax', 0),
(2168, 'J9', 73, 5, 'Ghế Imax', 0),
(2169, 'J10', 73, 5, 'Ghế Imax', 0),
(2170, 'J11', 73, 5, 'Ghế Imax', 0),
(2171, 'J12', 73, 5, 'Ghế Imax', 0),
(2172, 'A1', 74, 6, 'Ghế Thường', 0),
(2173, 'A2', 74, 6, 'Ghế Thường', 0),
(2174, 'A3', 74, 6, 'Ghế Thường', 0),
(2175, 'A4', 74, 6, 'Ghế Thường', 0),
(2176, 'A5', 74, 6, 'Ghế Thường', 0),
(2177, 'A6', 74, 6, 'Ghế Thường', 0),
(2178, 'A7', 74, 6, 'Ghế Thường', 0),
(2179, 'A8', 74, 6, 'Ghế Thường', 0),
(2180, 'A9', 74, 6, 'Ghế Thường', 0),
(2181, 'A10', 74, 6, 'Ghế Thường', 0),
(2182, 'A11', 74, 6, 'Ghế Thường', 0),
(2183, 'A12', 74, 6, 'Ghế Thường', 0),
(2184, 'B1', 74, 6, 'Ghế Thường', 0),
(2185, 'B2', 74, 6, 'Ghế Thường', 0),
(2186, 'B3', 74, 6, 'Ghế Thường', 0),
(2187, 'B4', 74, 6, 'Ghế Thường', 0),
(2188, 'B5', 74, 6, 'Ghế Thường', 0),
(2189, 'B6', 74, 6, 'Ghế Thường', 0),
(2190, 'B7', 74, 6, 'Ghế Thường', 0),
(2191, 'B8', 74, 6, 'Ghế Thường', 0),
(2192, 'B9', 74, 6, 'Ghế Thường', 0),
(2193, 'B10', 74, 6, 'Ghế Thường', 0),
(2194, 'B11', 74, 6, 'Ghế Thường', 0),
(2195, 'B12', 74, 6, 'Ghế Thường', 0),
(2196, 'C1', 74, 6, 'Ghế Thường', 0),
(2197, 'C2', 74, 6, 'Ghế Thường', 0),
(2198, 'C3', 74, 6, 'Ghế Thường', 0),
(2199, 'C4', 74, 6, 'Ghế Thường', 0),
(2200, 'C5', 74, 6, 'Ghế Thường', 0),
(2201, 'C6', 74, 6, 'Ghế Thường', 0),
(2202, 'C7', 74, 6, 'Ghế Thường', 0),
(2203, 'C8', 74, 6, 'Ghế Thường', 0),
(2204, 'C9', 74, 6, 'Ghế Thường', 0),
(2205, 'C10', 74, 6, 'Ghế Thường', 0),
(2206, 'C11', 74, 6, 'Ghế Thường', 0),
(2207, 'C12', 74, 6, 'Ghế Thường', 0),
(2208, 'D1', 74, 6, 'Ghế Thường', 0),
(2209, 'D2', 74, 6, 'Ghế Thường', 0),
(2210, 'D3', 74, 6, 'Ghế Thường', 0),
(2211, 'D4', 74, 6, 'Ghế Thường', 0),
(2212, 'D5', 74, 6, 'Ghế Thường', 0),
(2213, 'D6', 74, 6, 'Ghế Thường', 0),
(2214, 'D7', 74, 6, 'Ghế Thường', 0),
(2215, 'D8', 74, 6, 'Ghế Thường', 0),
(2216, 'D9', 74, 6, 'Ghế Thường', 0),
(2217, 'D10', 74, 6, 'Ghế Thường', 0),
(2218, 'D11', 74, 6, 'Ghế Thường', 0),
(2219, 'D12', 74, 6, 'Ghế Thường', 0),
(2220, 'E1', 74, 6, 'Ghế Thường', 0),
(2221, 'E2', 74, 6, 'Ghế Thường', 0),
(2222, 'E3', 74, 6, 'Ghế Thường', 0),
(2223, 'E4', 74, 6, 'Ghế Thường', 0),
(2224, 'E5', 74, 6, 'Ghế Thường', 0),
(2225, 'E6', 74, 6, 'Ghế Thường', 0),
(2226, 'E7', 74, 6, 'Ghế Thường', 0),
(2227, 'E8', 74, 6, 'Ghế Thường', 0),
(2228, 'E9', 74, 6, 'Ghế Thường', 0),
(2229, 'E10', 74, 6, 'Ghế Thường', 0),
(2230, 'E11', 74, 6, 'Ghế Thường', 0),
(2231, 'E12', 74, 6, 'Ghế Thường', 0),
(2232, 'F1', 74, 6, 'Ghế Thường', 0),
(2233, 'F2', 74, 6, 'Ghế Thường', 0),
(2234, 'F3', 74, 6, 'Ghế Thường', 0),
(2235, 'F4', 74, 6, 'Ghế Thường', 0),
(2236, 'F5', 74, 6, 'Ghế Thường', 0),
(2237, 'F6', 74, 6, 'Ghế Thường', 0),
(2238, 'F7', 74, 6, 'Ghế Thường', 0),
(2239, 'F8', 74, 6, 'Ghế Thường', 0),
(2240, 'F9', 74, 6, 'Ghế Thường', 0),
(2241, 'F10', 74, 6, 'Ghế Thường', 0),
(2242, 'F11', 74, 6, 'Ghế Thường', 0),
(2243, 'F12', 74, 6, 'Ghế Thường', 0),
(2244, 'G1', 74, 6, 'Ghế Thường', 0),
(2245, 'G2', 74, 6, 'Ghế Thường', 0),
(2246, 'G3', 74, 6, 'Ghế Thường', 0),
(2247, 'G4', 74, 6, 'Ghế Thường', 0),
(2248, 'G5', 74, 6, 'Ghế Thường', 0),
(2249, 'G6', 74, 6, 'Ghế Thường', 0),
(2250, 'G7', 74, 6, 'Ghế Thường', 0),
(2251, 'G8', 74, 6, 'Ghế Thường', 0),
(2252, 'G9', 74, 6, 'Ghế Thường', 0),
(2253, 'G10', 74, 6, 'Ghế Thường', 0),
(2254, 'G11', 74, 6, 'Ghế Thường', 0),
(2255, 'G12', 74, 6, 'Ghế Thường', 0),
(2256, 'H1', 74, 6, 'Ghế Thường', 0),
(2257, 'H2', 74, 6, 'Ghế Thường', 0),
(2258, 'H3', 74, 6, 'Ghế Thường', 0),
(2259, 'H4', 74, 6, 'Ghế Thường', 0),
(2260, 'H5', 74, 6, 'Ghế Thường', 0),
(2261, 'H6', 74, 6, 'Ghế Thường', 0),
(2262, 'H7', 74, 6, 'Ghế Thường', 0),
(2263, 'H8', 74, 6, 'Ghế Thường', 0),
(2264, 'H9', 74, 6, 'Ghế Thường', 0),
(2265, 'H10', 74, 6, 'Ghế Thường', 0),
(2266, 'H11', 74, 6, 'Ghế Thường', 0),
(2267, 'H12', 74, 6, 'Ghế Thường', 0),
(2268, 'I1', 74, 6, 'Ghế Thường', 0),
(2269, 'I2', 74, 6, 'Ghế Thường', 0),
(2270, 'I3', 74, 6, 'Ghế Thường', 0),
(2271, 'I4', 74, 6, 'Ghế Thường', 0),
(2272, 'I5', 74, 6, 'Ghế Thường', 0),
(2273, 'I6', 74, 6, 'Ghế Thường', 0),
(2274, 'I7', 74, 6, 'Ghế Thường', 0),
(2275, 'I8', 74, 6, 'Ghế Thường', 0),
(2276, 'I9', 74, 6, 'Ghế Thường', 0),
(2277, 'I10', 74, 6, 'Ghế Thường', 0),
(2278, 'I11', 74, 6, 'Ghế Thường', 0),
(2279, 'I12', 74, 6, 'Ghế Thường', 0),
(2280, 'J1', 74, 6, 'Ghế đôi', 0),
(2281, 'J2', 74, 6, 'Ghế đôi', 0),
(2282, 'J3', 74, 6, 'Ghế đôi', 0),
(2283, 'J4', 74, 6, 'Ghế đôi', 0),
(2284, 'J5', 74, 6, 'Ghế đôi', 0),
(2285, 'J6', 74, 6, 'Ghế đôi', 0),
(2286, 'J7', 74, 6, 'Ghế đôi', 0),
(2287, 'J8', 74, 6, 'Ghế đôi', 0),
(2288, 'J9', 74, 6, 'Ghế đôi', 0),
(2289, 'J10', 74, 6, 'Ghế đôi', 0),
(2290, 'J11', 74, 6, 'Ghế đôi', 0),
(2291, 'J12', 74, 6, 'Ghế đôi', 0),
(2292, 'A1', 75, 6, 'Ghế Thường', 0),
(2293, 'A2', 75, 6, 'Ghế Thường', 0),
(2294, 'A3', 75, 6, 'Ghế Thường', 0),
(2295, 'A4', 75, 6, 'Ghế Thường', 0),
(2296, 'A5', 75, 6, 'Ghế Thường', 0),
(2297, 'A6', 75, 6, 'Ghế Thường', 0),
(2298, 'A7', 75, 6, 'Ghế Thường', 0),
(2299, 'A8', 75, 6, 'Ghế Thường', 0),
(2300, 'A9', 75, 6, 'Ghế Thường', 0),
(2301, 'A10', 75, 6, 'Ghế Thường', 0),
(2302, 'A11', 75, 6, 'Ghế Thường', 0),
(2303, 'A12', 75, 6, 'Ghế Thường', 0),
(2304, 'B1', 75, 6, 'Ghế Thường', 0),
(2305, 'B2', 75, 6, 'Ghế Thường', 0),
(2306, 'B3', 75, 6, 'Ghế Thường', 0),
(2307, 'B4', 75, 6, 'Ghế Thường', 0),
(2308, 'B5', 75, 6, 'Ghế Thường', 0),
(2309, 'B6', 75, 6, 'Ghế Thường', 0),
(2310, 'B7', 75, 6, 'Ghế Thường', 0),
(2311, 'B8', 75, 6, 'Ghế Thường', 0),
(2312, 'B9', 75, 6, 'Ghế Thường', 0),
(2313, 'B10', 75, 6, 'Ghế Thường', 0),
(2314, 'B11', 75, 6, 'Ghế Thường', 0),
(2315, 'B12', 75, 6, 'Ghế Thường', 0),
(2316, 'C1', 75, 6, 'Ghế Thường', 0),
(2317, 'C2', 75, 6, 'Ghế Thường', 0),
(2318, 'C3', 75, 6, 'Ghế Thường', 0),
(2319, 'C4', 75, 6, 'Ghế Thường', 0),
(2320, 'C5', 75, 6, 'Ghế Thường', 0),
(2321, 'C6', 75, 6, 'Ghế Thường', 0),
(2322, 'C7', 75, 6, 'Ghế Thường', 0),
(2323, 'C8', 75, 6, 'Ghế Thường', 0),
(2324, 'C9', 75, 6, 'Ghế Thường', 0),
(2325, 'C10', 75, 6, 'Ghế Thường', 0),
(2326, 'C11', 75, 6, 'Ghế Thường', 0),
(2327, 'C12', 75, 6, 'Ghế Thường', 0),
(2328, 'D1', 75, 6, 'Ghế Thường', 0),
(2329, 'D2', 75, 6, 'Ghế Thường', 0),
(2330, 'D3', 75, 6, 'Ghế Thường', 0),
(2331, 'D4', 75, 6, 'Ghế Thường', 0),
(2332, 'D5', 75, 6, 'Ghế Thường', 0),
(2333, 'D6', 75, 6, 'Ghế Thường', 0),
(2334, 'D7', 75, 6, 'Ghế Thường', 0),
(2335, 'D8', 75, 6, 'Ghế Thường', 0),
(2336, 'D9', 75, 6, 'Ghế Thường', 0),
(2337, 'D10', 75, 6, 'Ghế Thường', 0),
(2338, 'D11', 75, 6, 'Ghế Thường', 0),
(2339, 'D12', 75, 6, 'Ghế Thường', 0),
(2340, 'E1', 75, 6, 'Ghế Thường', 0),
(2341, 'E2', 75, 6, 'Ghế Thường', 0),
(2342, 'E3', 75, 6, 'Ghế Thường', 0),
(2343, 'E4', 75, 6, 'Ghế Thường', 0),
(2344, 'E5', 75, 6, 'Ghế Thường', 0),
(2345, 'E6', 75, 6, 'Ghế Thường', 0),
(2346, 'E7', 75, 6, 'Ghế Thường', 0),
(2347, 'E8', 75, 6, 'Ghế Thường', 0),
(2348, 'E9', 75, 6, 'Ghế Thường', 0),
(2349, 'E10', 75, 6, 'Ghế Thường', 0),
(2350, 'E11', 75, 6, 'Ghế Thường', 0),
(2351, 'E12', 75, 6, 'Ghế Thường', 0),
(2352, 'F1', 75, 6, 'Ghế Thường', 0),
(2353, 'F2', 75, 6, 'Ghế Thường', 0),
(2354, 'F3', 75, 6, 'Ghế Thường', 0),
(2355, 'F4', 75, 6, 'Ghế Thường', 0),
(2356, 'F5', 75, 6, 'Ghế Thường', 0),
(2357, 'F6', 75, 6, 'Ghế Thường', 0),
(2358, 'F7', 75, 6, 'Ghế Thường', 0),
(2359, 'F8', 75, 6, 'Ghế Thường', 0),
(2360, 'F9', 75, 6, 'Ghế Thường', 0),
(2361, 'F10', 75, 6, 'Ghế Thường', 0),
(2362, 'F11', 75, 6, 'Ghế Thường', 0),
(2363, 'F12', 75, 6, 'Ghế Thường', 0),
(2364, 'G1', 75, 6, 'Ghế Thường', 0),
(2365, 'G2', 75, 6, 'Ghế Thường', 0),
(2366, 'G3', 75, 6, 'Ghế Thường', 0),
(2367, 'G4', 75, 6, 'Ghế Thường', 0),
(2368, 'G5', 75, 6, 'Ghế Thường', 0),
(2369, 'G6', 75, 6, 'Ghế Thường', 0),
(2370, 'G7', 75, 6, 'Ghế Thường', 0),
(2371, 'G8', 75, 6, 'Ghế Thường', 0),
(2372, 'G9', 75, 6, 'Ghế Thường', 0),
(2373, 'G10', 75, 6, 'Ghế Thường', 0),
(2374, 'G11', 75, 6, 'Ghế Thường', 0),
(2375, 'G12', 75, 6, 'Ghế Thường', 0),
(2376, 'H1', 75, 6, 'Ghế Thường', 0),
(2377, 'H2', 75, 6, 'Ghế Thường', 0),
(2378, 'H3', 75, 6, 'Ghế Thường', 0),
(2379, 'H4', 75, 6, 'Ghế Thường', 0),
(2380, 'H5', 75, 6, 'Ghế Thường', 0),
(2381, 'H6', 75, 6, 'Ghế Thường', 0),
(2382, 'H7', 75, 6, 'Ghế Thường', 0),
(2383, 'H8', 75, 6, 'Ghế Thường', 0),
(2384, 'H9', 75, 6, 'Ghế Thường', 0),
(2385, 'H10', 75, 6, 'Ghế Thường', 0),
(2386, 'H11', 75, 6, 'Ghế Thường', 0),
(2387, 'H12', 75, 6, 'Ghế Thường', 0),
(2388, 'I1', 75, 6, 'Ghế Thường', 0),
(2389, 'I2', 75, 6, 'Ghế Thường', 0),
(2390, 'I3', 75, 6, 'Ghế Thường', 0),
(2391, 'I4', 75, 6, 'Ghế Thường', 0),
(2392, 'I5', 75, 6, 'Ghế Thường', 0),
(2393, 'I6', 75, 6, 'Ghế Thường', 0),
(2394, 'I7', 75, 6, 'Ghế Thường', 0),
(2395, 'I8', 75, 6, 'Ghế Thường', 0),
(2396, 'I9', 75, 6, 'Ghế Thường', 0),
(2397, 'I10', 75, 6, 'Ghế Thường', 0),
(2398, 'I11', 75, 6, 'Ghế Thường', 0),
(2399, 'I12', 75, 6, 'Ghế Thường', 0),
(2400, 'J1', 75, 6, 'Ghế đôi', 0),
(2401, 'J2', 75, 6, 'Ghế đôi', 0),
(2402, 'J3', 75, 6, 'Ghế đôi', 0),
(2403, 'J4', 75, 6, 'Ghế đôi', 0),
(2404, 'J5', 75, 6, 'Ghế đôi', 0),
(2405, 'J6', 75, 6, 'Ghế đôi', 0),
(2406, 'J7', 75, 6, 'Ghế đôi', 0),
(2407, 'J8', 75, 6, 'Ghế đôi', 0),
(2408, 'J9', 75, 6, 'Ghế đôi', 0),
(2409, 'J10', 75, 6, 'Ghế đôi', 0),
(2410, 'J11', 75, 6, 'Ghế đôi', 0),
(2411, 'J12', 75, 6, 'Ghế đôi', 0),
(2412, 'A1', 76, 6, 'Ghế 4DX', 0),
(2413, 'A2', 76, 6, 'Ghế 4DX', 0),
(2414, 'A3', 76, 6, 'Ghế 4DX', 0),
(2415, 'A4', 76, 6, 'Ghế 4DX', 0),
(2416, 'A5', 76, 6, 'Ghế 4DX', 0),
(2417, 'A6', 76, 6, 'Ghế 4DX', 0),
(2418, 'A7', 76, 6, 'Ghế 4DX', 0),
(2419, 'A8', 76, 6, 'Ghế 4DX', 0),
(2420, 'A9', 76, 6, 'Ghế 4DX', 0),
(2421, 'A10', 76, 6, 'Ghế 4DX', 0),
(2422, 'A11', 76, 6, 'Ghế 4DX', 0),
(2423, 'A12', 76, 6, 'Ghế 4DX', 0),
(2424, 'B1', 76, 6, 'Ghế 4DX', 0),
(2425, 'B2', 76, 6, 'Ghế 4DX', 0),
(2426, 'B3', 76, 6, 'Ghế 4DX', 0),
(2427, 'B4', 76, 6, 'Ghế 4DX', 0),
(2428, 'B5', 76, 6, 'Ghế 4DX', 0),
(2429, 'B6', 76, 6, 'Ghế 4DX', 0),
(2430, 'B7', 76, 6, 'Ghế 4DX', 0),
(2431, 'B8', 76, 6, 'Ghế 4DX', 0),
(2432, 'B9', 76, 6, 'Ghế 4DX', 0),
(2433, 'B10', 76, 6, 'Ghế 4DX', 0),
(2434, 'B11', 76, 6, 'Ghế 4DX', 0),
(2435, 'B12', 76, 6, 'Ghế 4DX', 0),
(2436, 'C1', 76, 6, 'Ghế 4DX', 0),
(2437, 'C2', 76, 6, 'Ghế 4DX', 0),
(2438, 'C3', 76, 6, 'Ghế 4DX', 0),
(2439, 'C4', 76, 6, 'Ghế 4DX', 0),
(2440, 'C5', 76, 6, 'Ghế 4DX', 0),
(2441, 'C6', 76, 6, 'Ghế 4DX', 0),
(2442, 'C7', 76, 6, 'Ghế 4DX', 0),
(2443, 'C8', 76, 6, 'Ghế 4DX', 0),
(2444, 'C9', 76, 6, 'Ghế 4DX', 0),
(2445, 'C10', 76, 6, 'Ghế 4DX', 0),
(2446, 'C11', 76, 6, 'Ghế 4DX', 0),
(2447, 'C12', 76, 6, 'Ghế 4DX', 0),
(2448, 'D1', 76, 6, 'Ghế 4DX', 0),
(2449, 'D2', 76, 6, 'Ghế 4DX', 0),
(2450, 'D3', 76, 6, 'Ghế 4DX', 0),
(2451, 'D4', 76, 6, 'Ghế 4DX', 0),
(2452, 'D5', 76, 6, 'Ghế 4DX', 0),
(2453, 'D6', 76, 6, 'Ghế 4DX', 0),
(2454, 'D7', 76, 6, 'Ghế 4DX', 0),
(2455, 'D8', 76, 6, 'Ghế 4DX', 0),
(2456, 'D9', 76, 6, 'Ghế 4DX', 0),
(2457, 'D10', 76, 6, 'Ghế 4DX', 0),
(2458, 'D11', 76, 6, 'Ghế 4DX', 0),
(2459, 'D12', 76, 6, 'Ghế 4DX', 0),
(2460, 'E1', 76, 6, 'Ghế 4DX', 0),
(2461, 'E2', 76, 6, 'Ghế 4DX', 0),
(2462, 'E3', 76, 6, 'Ghế 4DX', 0),
(2463, 'E4', 76, 6, 'Ghế 4DX', 0),
(2464, 'E5', 76, 6, 'Ghế 4DX', 0),
(2465, 'E6', 76, 6, 'Ghế 4DX', 0),
(2466, 'E7', 76, 6, 'Ghế 4DX', 0),
(2467, 'E8', 76, 6, 'Ghế 4DX', 0),
(2468, 'E9', 76, 6, 'Ghế 4DX', 0),
(2469, 'E10', 76, 6, 'Ghế 4DX', 0),
(2470, 'E11', 76, 6, 'Ghế 4DX', 0),
(2471, 'E12', 76, 6, 'Ghế 4DX', 0),
(2472, 'F1', 76, 6, 'Ghế 4DX', 0),
(2473, 'F2', 76, 6, 'Ghế 4DX', 0),
(2474, 'F3', 76, 6, 'Ghế 4DX', 0),
(2475, 'F4', 76, 6, 'Ghế 4DX', 0),
(2476, 'F5', 76, 6, 'Ghế 4DX', 0),
(2477, 'F6', 76, 6, 'Ghế 4DX', 0),
(2478, 'F7', 76, 6, 'Ghế 4DX', 0),
(2479, 'F8', 76, 6, 'Ghế 4DX', 0),
(2480, 'F9', 76, 6, 'Ghế 4DX', 0),
(2481, 'F10', 76, 6, 'Ghế 4DX', 0),
(2482, 'F11', 76, 6, 'Ghế 4DX', 0),
(2483, 'F12', 76, 6, 'Ghế 4DX', 0),
(2484, 'G1', 76, 6, 'Ghế 4DX', 0),
(2485, 'G2', 76, 6, 'Ghế 4DX', 0),
(2486, 'G3', 76, 6, 'Ghế 4DX', 0),
(2487, 'G4', 76, 6, 'Ghế 4DX', 0),
(2488, 'G5', 76, 6, 'Ghế 4DX', 0),
(2489, 'G6', 76, 6, 'Ghế 4DX', 0),
(2490, 'G7', 76, 6, 'Ghế 4DX', 0),
(2491, 'G8', 76, 6, 'Ghế 4DX', 0),
(2492, 'G9', 76, 6, 'Ghế 4DX', 0),
(2493, 'G10', 76, 6, 'Ghế 4DX', 0),
(2494, 'G11', 76, 6, 'Ghế 4DX', 0),
(2495, 'G12', 76, 6, 'Ghế 4DX', 0),
(2496, 'H1', 76, 6, 'Ghế 4DX', 0),
(2497, 'H2', 76, 6, 'Ghế 4DX', 0),
(2498, 'H3', 76, 6, 'Ghế 4DX', 0),
(2499, 'H4', 76, 6, 'Ghế 4DX', 0),
(2500, 'H5', 76, 6, 'Ghế 4DX', 0),
(2501, 'H6', 76, 6, 'Ghế 4DX', 0),
(2502, 'H7', 76, 6, 'Ghế 4DX', 0),
(2503, 'H8', 76, 6, 'Ghế 4DX', 0),
(2504, 'H9', 76, 6, 'Ghế 4DX', 0),
(2505, 'H10', 76, 6, 'Ghế 4DX', 0),
(2506, 'H11', 76, 6, 'Ghế 4DX', 0),
(2507, 'H12', 76, 6, 'Ghế 4DX', 0),
(2508, 'I1', 76, 6, 'Ghế 4DX', 0),
(2509, 'I2', 76, 6, 'Ghế 4DX', 0),
(2510, 'I3', 76, 6, 'Ghế 4DX', 0),
(2511, 'I4', 76, 6, 'Ghế 4DX', 0),
(2512, 'I5', 76, 6, 'Ghế 4DX', 0),
(2513, 'I6', 76, 6, 'Ghế 4DX', 0),
(2514, 'I7', 76, 6, 'Ghế 4DX', 0),
(2515, 'I8', 76, 6, 'Ghế 4DX', 0),
(2516, 'I9', 76, 6, 'Ghế 4DX', 0),
(2517, 'I10', 76, 6, 'Ghế 4DX', 0),
(2518, 'I11', 76, 6, 'Ghế 4DX', 0),
(2519, 'I12', 76, 6, 'Ghế 4DX', 0),
(2520, 'J1', 76, 6, 'Ghế 4DX', 0),
(2521, 'J2', 76, 6, 'Ghế 4DX', 0),
(2522, 'J3', 76, 6, 'Ghế 4DX', 0),
(2523, 'J4', 76, 6, 'Ghế 4DX', 0),
(2524, 'J5', 76, 6, 'Ghế 4DX', 0),
(2525, 'J6', 76, 6, 'Ghế 4DX', 0),
(2526, 'J7', 76, 6, 'Ghế 4DX', 0),
(2527, 'J8', 76, 6, 'Ghế 4DX', 0),
(2528, 'J9', 76, 6, 'Ghế 4DX', 0),
(2529, 'J10', 76, 6, 'Ghế 4DX', 0),
(2530, 'J11', 76, 6, 'Ghế 4DX', 0),
(2531, 'J12', 76, 6, 'Ghế 4DX', 0);

--
-- Triggers `ghe_ngoi`
--
DELIMITER $$
CREATE TRIGGER `kt_ghe` AFTER INSERT ON `ghe_ngoi` FOR EACH ROW BEGIN
	declare marap_gn, marap_pc int;
    declare loaiphong, loaighe varchar(20);
	set marap_gn = new.marap;
	select pc.marap from phong_chieu as pc
		where pc.maphong = new.maphong into marap_pc;
	set loaighe = new.tenloai;
    select pc.tenloai from phong_chieu as pc
		where pc.maphong = new.maphong into loaiphong;
    IF marap_gn <> marap_pc THEN
    	DELETE FROM ghe_ngoi where ghe_ngoi.maghe = new.maghe;
    ELSEIF ((loaiphong = '4DX' AND loaighe <> 'Ghế 4DX') OR (loaiphong <> '4DX' AND loaighe = 'Ghế 4DX')) THEN
    	DELETE FROM ghe_ngoi where ghe_ngoi.maghe = new.maghe;
    ELSEIF ((loaiphong = 'Gold Class' AND loaighe <> 'Gold Class') OR (loaiphong <> 'Gold Class' AND loaighe = 'Gold Class')) THEN
    	DELETE FROM ghe_ngoi where ghe_ngoi.maghe = new.maghe;
    ELSEIF ((loaiphong = 'Imax' AND loaighe <> 'Ghế Imax') OR (loaiphong <> 'Imax' AND loaighe = 'Ghế Imax')) THEN
    	DELETE FROM ghe_ngoi where ghe_ngoi.maghe = new.maghe;
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `hoa_don`
--

CREATE TABLE `hoa_don` (
  `mahoadon` int NOT NULL,
  `tongtien` int NOT NULL DEFAULT '0',
  `ngayxuat` date DEFAULT NULL,
  `idkh` int DEFAULT NULL,
  `idnv` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `hoa_don`
--

INSERT INTO `hoa_don` (`mahoadon`, `tongtien`, `ngayxuat`, `idkh`, `idnv`) VALUES
(7, 55000, '2020-11-06', 3, 8),
(8, 55000, '2020-11-06', 3, 8),
(9, 55000, '2020-11-06', 3, 8),
(10, 55000, '2020-11-06', 3, 8),
(12, 55000, '2020-11-06', 14, 8),
(13, 70000, '2020-12-04', 14, 8),
(14, 60000, '2020-12-04', 14, 8),
(15, 70000, '2020-12-06', 14, 8),
(16, 120000, '2020-12-06', 14, 8),
(60, 45000, '2020-12-11', 14, 8),
(61, 45000, '2020-12-11', 14, 8),
(62, 45000, '2020-12-11', 18, 8),
(63, 45000, '2020-12-12', 19, 8),
(64, 55000, '2020-12-12', 19, 8),
(65, 70006, '2020-12-12', 19, 8),
(66, 170000, '2020-12-12', 19, 8);

--
-- Triggers `hoa_don`
--
DELIMITER $$
CREATE TRIGGER `kt_khuyen_mai` AFTER INSERT ON `hoa_don` FOR EACH ROW BEGIN
	DECLARE done, khmai INT DEFAULT 0;
	declare day1, day2 date;
	DECLARE money_cursor CURSOR FOR select km.makm, km.batdau, km.ketthuc from khuyen_mai as km;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN money_cursor;
	read_loop: LOOP
		FETCH money_cursor into khmai, day1, day2;
		IF done THEN
 		     LEAVE read_loop;
		END IF;
        IF ((new.ngayxuat >= day1) AND (new.ngayxuat <= day2)) THEN
        	insert INTO hoa_don_khuyen_mai values (new.mahoadon, khmai);
        END IF;
	END LOOP;
	CLOSE money_cursor;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `hoa_don_khuyen_mai`
--

CREATE TABLE `hoa_don_khuyen_mai` (
  `mahoadon` int NOT NULL,
  `makm` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `khach_hang`
--

CREATE TABLE `khach_hang` (
  `idkh` int NOT NULL,
  `capdo` varchar(10) DEFAULT NULL,
  `diemtichluy` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `khach_hang`
--

INSERT INTO `khach_hang` (`idkh`, `capdo`, `diemtichluy`) VALUES
(1, 'C', 297),
(2, 'D', 0),
(3, 'D', 0),
(4, 'D', 5),
(5, 'VIP', 110),
(6, 'A', 90),
(7, 'B', 70),
(14, 'D', 0),
(17, 'D', 0),
(18, 'D', 0),
(19, 'D', 0);

-- --------------------------------------------------------

--
-- Table structure for table `khung_gio`
--

CREATE TABLE `khung_gio` (
  `makhunggio` int NOT NULL,
  `batdau` varchar(10) DEFAULT NULL,
  `ketthuc` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `khung_gio`
--

INSERT INTO `khung_gio` (`makhunggio`, `batdau`, `ketthuc`) VALUES
(1, '09:30', '12:00'),
(2, '12:00', '14:30'),
(3, '14:30', '17:00'),
(4, '17:00', '19:30'),
(5, '19:30', '22:00'),
(6, '22:00', '00:30');

-- --------------------------------------------------------

--
-- Table structure for table `khuyen_mai`
--

CREATE TABLE `khuyen_mai` (
  `id` int NOT NULL,
  `tenkm` varchar(50) DEFAULT NULL,
  `mota` text,
  `batdau` date DEFAULT NULL,
  `giamgia` float DEFAULT NULL,
  `ketthuc` date DEFAULT NULL,
  `hinhanh` varchar(500) DEFAULT NULL,
  `makm` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `khuyen_mai`
--

INSERT INTO `khuyen_mai` (`id`, `tenkm`, `mota`, `batdau`, `giamgia`, `ketthuc`, `hinhanh`, `makm`) VALUES
(1, 'Sneak Show', 'Suất chiếu đặc biệt', '2021-02-14', 0.1, '2021-02-14', 'https://www.cgv.vn/media/banner/cache/1/b58515f018eb873dafa430b6f9ae0c1e/w/w/ww84_viral5x1_980x448.jpg', 0),
(2, 'Festival week', 'Tuần lễ hội', '2021-02-14', 0.1, '2021-02-14', 'https://www.cgv.vn/media/banner/cache/1/b58515f018eb873dafa430b6f9ae0c1e/c/g/cgv-brand-team-phim-hay-thang-12-980x448.jpg', 0),
(3, 'Movie Release Day', 'Ngày khởi chiếu', '2021-03-08', 0.1, '2021-03-08', 'https://www.cgv.vn/media/banner/cache/1/b58515f018eb873dafa430b6f9ae0c1e/n/s/nsk-ns-_980x448_.jpg', 0),
(4, 'Movie Release Day', 'Công chiếu phim mới', '2020-12-25', 0.2, '2020-12-25', 'https://www.cgv.vn/media/banner/cache/1/b58515f018eb873dafa430b6f9ae0c1e/9/8/980x448_2__4.jpg', 0),
(5, 'Boxing Day', 'Ngày tặng quà', '2020-12-22', 0.2, '2020-12-22', 'https://www.cgv.vn/media/banner/cache/1/b58515f018eb873dafa430b6f9ae0c1e/q/u/qua_tang_980x448.jpg', 0),
(6, 'Meeting Day', 'Họp báo ra mắt phim', '2020-12-24', 0.2, '2020-12-24', 'https://www.cgv.vn/media/banner/cache/1/b58515f018eb873dafa430b6f9ae0c1e/9/8/980x448-min_1_.png', 0),
(7, 'Christmas', 'Khuyến mãi Giáng sinh', '2021-02-14', 0.1, '2021-02-14', 'https://www.cgv.vn/media/banner/cache/1/b58515f018eb873dafa430b6f9ae0c1e/c/g/cgv-grab-980x448.jpg', 0),
(8, 'Online Tickets', 'Khuyến mãi mua vé online', '2020-12-24', NULL, '2020-12-24', 'https://www.cgv.vn/media/banner/cache/1/b58515f018eb873dafa430b6f9ae0c1e/a/p/app_980x448_1.jpg', 0);

-- --------------------------------------------------------

--
-- Table structure for table `loai_ghe`
--

CREATE TABLE `loai_ghe` (
  `tenloai` varchar(10) NOT NULL,
  `gia` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `loai_ghe`
--

INSERT INTO `loai_ghe` (`tenloai`, `gia`) VALUES
('bbb', 100000),
('Ghế 4DX', 200000),
('Ghế Imax', 250000),
('Ghế Thường', 45000),
('Ghế đôi', 100000),
('Giường nằm', 400000),
('Gold Class', 300000);

-- --------------------------------------------------------

--
-- Table structure for table `loai_phong`
--

CREATE TABLE `loai_phong` (
  `tenloai` varchar(10) NOT NULL,
  `gia` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `loai_phong`
--

INSERT INTO `loai_phong` (`tenloai`, `gia`) VALUES
('3D', 60000),
('4DX', 200000),
('aaa', 100002),
('Gold Class', 400000),
('Imax', 150000),
('Thường', 45000);

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `nhan_vien`
--

CREATE TABLE `nhan_vien` (
  `idnv` int NOT NULL,
  `anhdaidien` varchar(500) DEFAULT NULL,
  `ngaybatdau` date DEFAULT NULL,
  `chucvu` varchar(50) DEFAULT NULL,
  `marap` int NOT NULL,
  `idquanly` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `nhan_vien`
--

INSERT INTO `nhan_vien` (`idnv`, `anhdaidien`, `ngaybatdau`, `chucvu`, `marap`, `idquanly`) VALUES
(8, 'https://scontent.fsgn8-1.fna.fbcdn.net/v/t1.0-9/27544899_2112039145692527_4574425775502617674_n.jpg?_nc_cat=0&_nc_eui2=AeEd9zJ18bK5ZRzXNmwGsn5ydrI_etyxbX7xoQt3qDteQSefybf4VruJsEYcW4QO3zg7uf1ymhpvZZ0jFZK0g2WmM7gAgKhki3igFC0BND-QcQ&oh=3bf94b3c9cc7f1a7bedab17bd13de718&oe=5B84AF8B', '2018-05-15', 'Bán vé', 3, 11),
(9, 'https://scontent.fsgn8-1.fna.fbcdn.net/v/t1.0-9/32598574_1334443983323691_4755508246783983616_n.jpg?_nc_cat=0&_nc_eui2=AeFEteDv9BorLQDR-V2qIE6x3lNbvLUc7tchwaenq410X65-Ik1OpHwj6JpPfnX5-jVSrjKHjGsR0nO6kuS5ryizg52A8-aWRxQ0cf4yCEovbQ&oh=e68eda6f2a37d7a8deb102620111b0ce&oe=5B969C7E', '2015-09-15', 'Bán vé', 5, 11),
(10, 'https://scontent.fsgn8-1.fna.fbcdn.net/v/t1.0-1/28661097_739455619587322_1604038202721761123_n.jpg?_nc_cat=0&_nc_eui2=AeFeIn58bfZiPcnG_goyUDyfuDYn8ndWJaK7mp1g4SJskQEyhWobNpv09g9BK2Kqfe0rgaIOtvwy5-hQvO2YcNYFc9_rHRPxUWP91fwXHU42Hw&oh=b033ce6fe5142670acb5dd07eb5a2df9&oe=5B783F35', '2017-09-15', 'Bán vé', 1, 11),
(11, 'https://scontent.fsgn8-1.fna.fbcdn.net/v/t1.0-9/20664575_847255178773864_2973611719685943201_n.jpg?_nc_cat=0&_nc_eui2=AeFKAT3r-6xyO9HNIwItkjPhlgHbef5AvhgWNmmov-NVJNMdgwZdMdli6qXl5KCloNrlbiKHE4Hl8FTexrv1cH8W3gIe3p3esq4HdsH6vOlQ9w&oh=ad635f4c482d25ddcb939fc8374bdab1&oe=5B7DA261', '2016-08-15', 'Bán vé, quản lý', 6, NULL),
(12, 'https://scontent.fsgn8-1.fna.fbcdn.net/v/t1.0-1/32294622_2020570854870618_8840139440836837376_n.jpg?_nc_cat=0&_nc_eui2=AeGlwbv4fJNGTq3TLeil9Mhm3YaPIuP2xai_A9iZlKk5gJpW0OsW9XhqOHVTucpJEpfu75zN28GYkMOnrWBkhZBa_jgpsYc1n6Ny-TizRv5B4A&oh=fede4855cc363ed8901d0e1b6847753d&oe=5B98AC51', '2018-05-15', 'Bán vé', 4, 11),
(13, 'https://scontent.fsgn8-1.fna.fbcdn.net/v/t1.0-9/32511958_2070093176648254_1424641236198752256_n.jpg?_nc_cat=0&_nc_eui2=AeHdbD4zrIqTn9HfBLwhPRmouejTjrIkL-LKnPTzFSK6c0467Nbl5X_3BmBFF83Mi_MGijPcj2sJ6j7YF8vTv6ZsLNyPUAPN9FASBvqziEfNqg&oh=b4e8417280aa4f123412ec9a01570651&oe=5B95826F', '2016-08-15', 'Bán vé', 5, 11),
(20, 'https://scontent.fhan2-1.fna.fbcdn.net/v/t1.0-0/c0.150.640.640a/s552x414/118918203_826538801421657_7497952422851580111_n.jpg?_nc_cat=106&ccb=2&_nc_sid=da31f3&_nc_ohc=3gmftgwNgwEAX_IF-gT&_nc_ht=scontent.fhan2-1.fna&tp=28&oh=85149ecc2957ac8790e4d7518536821a&oe=5FFF6657', '2020-12-16', 'Quản lý', 6, 11);

-- --------------------------------------------------------

--
-- Table structure for table `phim`
--

CREATE TABLE `phim` (
  `maphim` int NOT NULL,
  `tenphim` varchar(50) DEFAULT NULL,
  `daodien` varchar(100) DEFAULT NULL,
  `doituong` varchar(10) DEFAULT NULL,
  `ngonngu` varchar(100) DEFAULT NULL,
  `batdau` date DEFAULT NULL,
  `ketthuc` date DEFAULT NULL,
  `mota` varchar(1000) DEFAULT NULL,
  `trailer` varchar(255) DEFAULT NULL,
  `thoiluong` varchar(20) DEFAULT NULL,
  `hinhanh` varchar(400) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `phim`
--

INSERT INTO `phim` (`maphim`, `tenphim`, `daodien`, `doituong`, `ngonngu`, `batdau`, `ketthuc`, `mota`, `trailer`, `thoiluong`, `hinhanh`) VALUES
(1, 'PHIM DORAEMON: NOBITA VÀ NHỮNG BẠN KHỦNG LONG MỚI', 'Kazuaki Imai', 'P', 'Tiếng Nhật - Phụ đề Tiếng Việt; Lồng tiếng', '2020-12-18', '2021-02-10', 'Trong lúc đang tham gia hoạt động khảo cổ ở một cuộc triễn lãm khủng long, Nobita tình cờ tìm thấy một viên hóa thạch và cậu tin rằng đây là trứng khủng long. Nobita liền mượn bảo bối thần kỳ \"khăn trùm thời gian\" của Doraemon để giúp viên hóa thạch trở lại thời của chúng nhưng ngay sau đó, quả trứng liền nở ra một cặp khủng long song sinh. Ngạc nhiên hơn hết, đây lại là loài khủng long mới hoàn toàn và chưa từng được phát hiện.', 'https://youtu.be/2vdLzk15Z0w', '110 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/v/e/vertical_1.jpg'),
(2, 'THANH GƯƠM DIỆT QUỶ - CHUYẾN TÀU VÔ TẬN', 'Haruo Sotozaki', 'C13', 'Tiếng Nhật - Phụ đề Tiếng Anh và Tiếng Việt', '2020-12-11', '2021-01-20', 'Trên đường điều tra sự mất tích của các Kiếm Sĩ thuộc Đội Diệt Quỷ, Tanjiro và các đồng đội cùng Viêm Trụ Rengoku rơi vào Huyết Quỷ Thuật ảo mộng của Quỷ Hạ Huyền Enmu. Cả bọn phải hiệp lực để bảo toàn tính mạng cho 200 hành khách trên chuyến tàu Vô Tận. Nhờ sự hi sinh của Viêm Trụ Rengoku, Quỷ Hạ Huyền đã bị đánh bại và mọi người được sống sót', 'https://www.youtube.com/watch?v=zP0t8FzrvK8&feature=youtu.be', '117 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/d/s/dsmt_kv_vie_11_1.jpg'),
(3, 'TIỆC TRĂNG MÁU', 'Nguyễn Quang Dũng', 'C18', 'Tiếng Việt - Phụ đề Tiếng Anh', '2020-10-23', '2020-12-30', 'Trong buổi họp mặt của nhóm bạn thân, một thành viên bất ngờ đề xuất trò chơi chia sẻ điện thoại nhằm tăng tinh thần “đoàn kết”. Từ đó, những góc khuất của từng người dần hé lộ và khiến cho mối quan hệ vốn khắng khít của họ bắt đầu lay chuyển.', 'https://youtu.be/PqNGHKLyPD0', '118 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/t/t/ttm_main-poster_2__1.jpg'),
(4, 'TRỤC QUỶ', 'Christopher Smith', 'C18', 'Tiếng Anh - Phụ đề Tiếng Việt', '2020-12-04', '2021-01-31', 'Trục Quỷ lấy bối cảnh nước Anh đầu những năm 1930 khi Mục sư Linus cùng vợ là Marianne và con gái Adelaide chuyển tới một thị trấn nhỏ ở Anh. Linus được Giáo hội giao nhiệm vụ khôi phục đức tin của dân làng sau khi gia đình Mục sư trước biến mất một cách bí ẩn ngay trong chính căn nhà mà anh vừa dọn vào.', 'https://youtu.be/Pdcbdi_a_Y8', '92 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/t/h/thebanishing_poster__1.jpg'),
(5, 'NGHỀ SIÊU KHÓ', 'Lee Byeong-heon', 'C18', 'Tiếng Hàn - Phụ đề Tiếng Việt', '2020-12-11', '2021-02-10', 'Nhóm điều tra do đội trưởng Ko (Ryu Seung-yong) lãnh đạo đứng trước nguy cơ giải tán nhờ chuỗi “thành tích” thất bại đáng nể. Cơ hội cuối cùng để cứu vớt sự nghiệp của họ chính là phải triệt phá một băng đảng buôn bán ma tuý tầm cỡ quốc tế. Để làm được điều đó, đội trưởng Ko và các thành viên trong nhóm đã cải trang thành những nhân viên bán gà tại một quán ăn ngay đối diện hang ổ của kẻ địch. Trớ trêu thay, món gà rán của họ quá ngon và nhà hàng bỗng chốc nổi như cồn, căn cứ địa có nguy cơ bại lộ khiến 5 cảnh sát chìm rơi vào những nguy hiểm khó lường.', 'https://youtu.be/wEunhJFDPuw', '111 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/r/s/rsz_2teaser_poster_nsk_1.jpg'),
(6, 'CUỘC CHIẾN HỦY DIỆT', 'Liam O\'Donnell', 'C18', 'Tiếng Anh - Phụ đề Tiếng Việt', '2020-12-11', '2021-01-25', 'SKYLIN3S - phim hành động giả tưởng, xoay quanh cuộc xâm lăng Trái Đất của một chủng tộc người ngoài hành tinh. 15 năm sau kết thúc của phần hai, một loại virus mới đã xuất hiện và xâm nhập vào những người ngoài hành tinh đang sinh sống trên Trái Đất. Loại virus này khiến những sinh vật từ thân thiện trở nên hung hãn và chống lại con người. Đội trưởng Rose Corley phải lãnh đạo một đội lính đánh thuê tinh thuệ, tham gia nhiệm vụ đến thế giới ngoài hành tinh để cứu những gì còn lại của nhân loại.', 'https://youtu.be/zeQAQK3g0kw', '114 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/r/s/rsz_poster__cchd_2_1.jpg'),
(7, 'VIOLET EVERGARDEN: HỒI ỨC KHÔNG QUÊN', 'Taichi Ishidate', 'P', 'Tiếng Nhật - Phụ đề Tiếng Việt', '2020-12-04', '2021-01-11', 'Nhiều năm sau chiến tranh, \"Búp bê ký ức\" Violet Evergarden vẫn mãi nhớ về Thiếu tá Gilbert. Một ngày nọ, cô gặp Dietfried - anh trai của Gilbert, người khuyên cô hãy cố quên Gilbert và bắt đầu cuộc sống mới. Nhưng với Violet, điều đó là không thể. Chôn sâu hình bóng của người quan trọng trong lòng, Violet Evergarden vẫn phải cố gắng sống trong thế giới không có người đó… Ngày Violet học được cách yêu thương, Người dạy cô biết yêu thương không còn bên cạnh nữa...', 'https://youtu.be/gSFbyzpd1EM', '140 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/r/s/rsz_violet_evergarden_the_movie-_vietnamese_poster_1.jpg'),
(8, 'TRỐN CHẠY', 'Aneesh Chaganty', 'C16', 'Tiếng Anh - Phụ đề Tiếng Việt', '2020-11-20', '2020-12-25', 'Tuyệt tác từ đội ngũ biên kịch, sản xuất & đạo diễn của SEARCHING. Liệt nửa người và mắc phải nhiều chứng bệnh mãn tính từ lúc lọt lòng, cuộc sống của Chloe đến tận năm 17 tuổi chỉ xoay quanh mẹ mình Diane và gần như bị cô lập với thế giới bên ngoài. Đến khi phát hiện ra bí mật khủng khiếp mẹ đang cố gắng che giấu, Chloe biết mình cần phải trốn chạy khỏi cái lồng vô hình đã giam giữ bản thân bấy lâu nay.', 'https://youtu.be/4njwSo51I5M', '90 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/r/u/run_-_localized_poster_-_vietnam_-_oct_20_1__1.jpg'),
(9, 'ĐỘI DO THÁM', 'Robert Port', 'C18', 'Tiếng Anh - Phụ đề Tiếng Việt', '2020-12-04', '2021-03-10', 'Bốn người lính Mỹ bước ra khỏi cuộc leo núi khắc nghiệt của một sườn núi ở Ý trong những ngày kết thúc của Chiến tranh thế giới thứ hai. Bị ám ảnh bởi tên trung sĩ máu lạnh của họ đã giết chết một phụ nữ trẻ và trên con đường do thám, họ đi theo một người đàn ông già người Ý nói rằng ông ta biết nơi ẩn náu của kẻ địch mà không biết rằng chuyến đi chết chóc đang chờ đợi họ phía trước.', 'https://youtu.be/EFdAorR0jO4', '96 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/r/s/rsz_poster__ddt__op1_2_final_1.jpg'),
(10, 'GIA ĐÌNH CROODS: KỶ NGUYÊN MỚI', 'Joel Crawford', 'P', 'Tiếng Anh - Phụ đề Tiếng Việt', '2020-11-27', '2020-12-30', 'Sinh tồn trong một thế giới tiền sử luôn rình rập hiểm nguy từ đủ loài quái thú hung dữ cho tới thảm họa ngày tận thế, Nhà Croods chưa từng một lần chùn bước. Nhưng giờ đây họ sẽ phải đối mặt với thử thách lớn nhất từ trước tới nay: chung sống với một gia đình khác. Để tìm kiếm một mái nhà an toàn hơn, Nhà Croods bắt đầu hành trình khám phá thế giới tiến tới những vùng đất xa xôi đầy tiềm năng. Một ngày nọ, họ tình cờ lạc vào một nơi yên bình có đầy đủ mọi tiện nghi hiện đại và biệt lập với tường vây bao quanh. Tưởng rằng mọi vấn đề trong cuộc sống sẽ được giải quyết thì Nhà Croods lại phải chấp nhận với sự thật rằng đã có một gia đình khác định cư ở đây đó chính là Nhà Bettermans.', 'https://youtu.be/D6P0xcxonXo', '96 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/r/s/rsz_cr2_digtal1sheet_action_vie_1.jpg'),
(11, 'MINIONS: SỰ TRỖI DẬY CỦA GRU', 'Kyle Balda, Brad Ableson, Jonathan del Val', 'P', 'Tiếng Anh với phụ đề tiếng Việt và lồng tiếng Việt', '2021-07-02', '2021-09-02', 'Hành trình phiêu lưu của #Gru song hành cùng với #Otto và viên đá của ác nhân MINIONS: SỰ TRỖI DẬY CỦA GRU - DCKC: 2021', 'https://youtu.be/SC7BfxpWieM', '100 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/m/i/minion_2020_1.jpg'),
(12, 'WONDER WOMAN 1984: NỮ THẦN CHIẾN BINH', 'Patty Jenkins', 'C13', 'Tiếng Anh với phụ đề tiếng Việt', '2020-12-18', '2021-02-10', 'Lấy bối cảnh năm 1984, 66 năm sau sự kiện diễn ra Thế Chiến thứ I (1918) ở phần phim đầu tiên, Wonder Woman tái hợp với người yêu tưởng chừng đã qua đời Steve Trevor, đồng thời đương đầu với hai kẻ thù mới là Max Lord và The Cheetah.', 'https://youtu.be/9ihTMGouLms', '151 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/w/w/ww84_viral5x1_406x600_1.jpg'),
(13, 'CHỊ MƯỜI BA', 'Tô Gia Tuấn, Khương Ngọc', 'C13', 'Tiếng tiếng Việt, phụ đề tiếng Anh', '2020-12-25', '2021-02-10', 'Chị Mười Ba đưa Kẽm Gai, tay đàn em cũ vừa mới ra tù, lên Đà Lạt để làm việc cho tiệm Gara của mình. Tại đây, Kẽm Gai dường như đã tìm lại được sự bình yên và hạnh phúc. Tuy vậy, anh sớm trở thành đối tượng bị tình nghi giết hại Đức Mát - em trai của đại ca Thắng Khùng khét tiếng đất Đà Lạt - và phải trốn chạy. Với thời hạn chỉ ba ngày, liệu Chị Mười Ba có minh oan được cho Kẽm Gai và cứu anh em An Cư Nghĩa Đoàn khỏi mối đe doạ mới? Liệu có bí mật khủng khiếp nào khác đang được che giấu? Tất cả sẽ được hé lộ vào ngày 27/03/2020\r\n', 'https://youtu.be/HmBvoXsU83Q', '110 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/r/s/rsz_ch__m_i_ba_3_nst_official_poster_kc_25122020_1.jpg'),
(14, 'TRẠNG TÍ', 'Phan Gia Nhật Linh', 'P', 'Tiếng Việt - Phụ đề Tiếng Anh', '2021-02-12', '2021-04-13', 'Trạng Tí Phiêu Lưu Kí là chuyến phiêu lưu vượt ngoài trí tưởng tượng của bộ tứ Tí - Sửu - Dần - Mẹo khi phải cùng nhau vượt qua rất nhiều thử thách để khám phá bí ẩn về cha Tí. Truyền thuyết Hai Hậu sinh ra Tí vì tựa vào cục đá nghe thật khó tin, nên Tí trở thành tâm điểm chọc phá và coi thường bởi những người xấu tính trong làng. Trên hành trình, bốn đứa trẻ nhiều lần gặp rắc rối, hiểu lầm, tai nạn. Và bất ngờ, bốn đứa trẻ lại bị sơn tặc bắt cóc và bị ép đối đầu trước một âm mưu không thể lường trước được. Nhưng, nhờ những trải nghiệm và có bạn bè bên cạnh những lúc khó khăn đó, Tí dần hoàn thiện tính cách bản thân, bớt háo thắng và biết quan tâm đến người khác, hiểu rằng, cái lý đôi khi không quan trọng bằng cái tình mà con người ta dành cho nhau.', 'https://youtu.be/vJGYMQucxpg', '110 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/s/6/s68_trangti_teaserposter201102_final_1__1.jpg'),
(15, 'THỢ SĂN QUÁI VẬT', 'Paul W.S. Anderson', 'C13', 'Tiếng Anh - Phụ đề Tiếng Việt', '2020-12-30', '2021-02-20', 'Monster Hunter được chuyển thể từ series game nổi tiếng cùng tên của Capcom. Trong phim, đội trưởng Artemis của nữ diễn viên Milla Jovovich (Resident Evil) và đồng đội đã vô tình bước qua một cánh cửa bí ẩn dẫn tới thế giới khác. Tại đây, họ phải chiến đấu với nhiều loài quái vật khổng lồ trong hành trình trở về thế giới. Đồng hành với họ trong trận chiến là nhân vật “Thợ săn” của nam diễn viên Tony Jaa (Ong Bak). Monster Hunter hứa hẹn sẽ là bom tấn hành động với những màn săn quái vật khổng lồ hoành tráng nhất năm 2020.', 'https://youtu.be/puQyZsaTtqY', '100 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/p/o/poster_-mh_1__1.jpg'),
(16, 'TOM & JERRY', 'Tim Story', 'P', 'Tiếng Anh với phụ đề tiếng Việt và lồng tiếng Việt', '2021-03-05', '2021-05-10', 'Tom và Jerry nay đã trở lại, lợi hại hơn xưa... ', 'https://youtu.be/1ue84WhBdK4', '107 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/t/o/tom_jerry_1.jpg'),
(17, 'VÙNG ĐẤT CÂM LẶNG II', 'John Krasinski', 'C16', 'Tiếng Anh - Phụ đề Tiếng Việt', '2020-04-23', '2021-06-12', 'Phần hai tiếp nối các sự kiện xảy ra trong phần một, khi gia đình Abbot gồm người mẹ Evelyn (do Emily Blunt thủ vai) cùng ba con chạy trốn đến một thành phố tưởng như an toàn. Tuy nhiên, cả gia đình không ngờ rằng ở thế giới bên ngoài cũng đã bị những sinh vật ngoài hành tinh thâu tóm. Những sinh vật này khiếm khuyết về thị giác nhưng có thính giác siêu nhạy để săn mồi bằng cách lần theo âm thanh. “Vùng đất câm lặng” lúc này đã trở thành “thế giới câm lặng” khi những người sống sót tiếp tục phải lẩn trốn, không được tạo ra tiếng động mỗi khi di chuyển hay giao tiếp với nhau. Nhưng càng bước ra ngoài thế giới, gia đình Abbot sớm nhận ra rằng hiểm họa duy nhất không chỉ đến từ những sinh vật ngoài hành tinh. Những bí ẩn xung quanh cuộc đổ bộ của các giống loài này dần được hé lộ…', 'https://youtu.be/OObI02klU6E', '118 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/a/q/aqp2_intl_tsr_dgtl_1_sht_imax_vie_1.jpg'),
(18, 'NHÓC TRÙM: NỐI NGHIỆP GIA ĐÌNH', 'Tom McGrath', 'P', 'Tiếng Anh với phụ đề tiếng Việt và lồng tiếng Việt', '2021-03-26', '2021-05-30', 'Nhóc trùm Ted giờ đây đã trở thành một triệu phú nổi tiếng trong khi Tim lại có một cuộc sống đơn giản bên vợ anh Carol và hai cô con gái nhỏ yêu dấu. Mỗi mùa Giáng sinh tới, cả Tina và Tabitha đều mong được gặp chú Ted nhưng dường như hai anh em nhà Templeton nay đã không còn gần gũi như xưa. Nhưng bất ngờ thay khi Ted lại có màn tái xuất không thể hoành tráng hơn khi đáp thẳng máy bay trực thăng tới nhà Tim trước sự ngỡ ngàng của cả gia đình.', 'https://youtu.be/Lv8nL2q8yRI', NULL, 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/n/h/nh_c_tr_m_n_i_nghi_p_gia_nh_1.jpg'),
(19, 'TỘI ÁC LẶNG THINH', 'Kim Jung Sik', 'C13', 'Tiếng Hàn - Phụ đề Tiếng Việt', '2020-12-11', '2021-02-10', 'Do bị thiểu năng, nên chàng thanh niên Seokgu có tính tình lẫn trí tuệ chẳng khác nào đứa trẻ vừa lên 8. Một ngày nọ, cô bé Eunji, người mà anh xem như bạn tri kỉ, được phát hiện trong tình trạng không mảnh vải che thân tại nhà Seokgu. Vì vậy, người dân trong làng đều nghi ngờ Seokgu là thủ phạm và bắt đầu xua đuổi, kì thị cậu ta. Liệu sự thật có được phơi bày?', 'https://youtu.be/c2moD-W_hBA', '107 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/t/_/t_i_c_thinh_l_ng_main-poster_1.jpg'),
(20, 'JOSÉE, NÀNG THƠ CỦA TÔI', 'Kim Jong Kwan', 'P', 'Tiếng Hàn - Phụ đề Tiếng Việt', '2020-12-18', '2021-02-05', 'Bộ phim là câu chuyện tình nên thơ của cậu sinh viên Young Seok (Nam Joo Hyuk) và Josée (Han Ji Min), một cô gái khuyết tật phải ngồi xe lăn vào mùa đông lạnh lẽo. Cuộc gặp gỡ đã khiến thế giới của Josée thay đổi, những ngày tháng đẹp nhất trong cuộc đời họ bắt đầu. Josée muốn được bước ra thế giới bên ngoài, cùng Young Seok đến nơi thật xa nhưng giữa họ có quá nhiều trở ngại. Liệu Young Seok có bên cạnh Josée đi đến tận cùng?', 'https://youtu.be/Dw6myHkqtcQ', '95 phút', 'https://www.cgv.vn/media/catalog/product/cache/1/small_image/190x260/052b7e4a4f6d2886829431e534ef7a43/r/s/rsz_josee_mainposter_23112020_1.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `phong_chieu`
--

CREATE TABLE `phong_chieu` (
  `maphong` int NOT NULL,
  `marap` int NOT NULL,
  `soghe` int DEFAULT NULL,
  `tenloai` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `phong_chieu`
--

INSERT INTO `phong_chieu` (`maphong`, `marap`, `soghe`, `tenloai`) VALUES
(57, 1, 30, '3D'),
(58, 1, 50, 'Thường'),
(59, 1, 40, 'Imax'),
(60, 2, 50, 'Thường'),
(61, 2, 40, 'Imax'),
(62, 2, 30, '3D'),
(63, 2, 30, '4DX'),
(64, 3, 40, '3D'),
(65, 3, 30, 'Gold Class'),
(66, 3, 50, '4DX'),
(67, 4, 40, 'Thường'),
(68, 4, 50, 'Imax'),
(69, 4, 30, '3D'),
(70, 5, 40, 'Thường'),
(71, 5, 50, 'Gold Class'),
(72, 5, 30, '4DX'),
(73, 5, 30, 'Imax'),
(74, 6, 50, '3D'),
(75, 6, 30, 'Thường'),
(76, 6, 40, '4DX');

-- --------------------------------------------------------

--
-- Table structure for table `rap_chieu`
--

CREATE TABLE `rap_chieu` (
  `marap` int NOT NULL,
  `maqh` int NOT NULL,
  `tenrap` varchar(50) DEFAULT NULL,
  `daichi` varchar(100) DEFAULT NULL,
  `sodt` varchar(20) DEFAULT NULL,
  `soluongphong` int DEFAULT NULL,
  `giomo` time DEFAULT NULL,
  `giodong` time DEFAULT NULL,
  `mota` varchar(500) DEFAULT NULL,
  `hinh_anh` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `rap_chieu`
--

INSERT INTO `rap_chieu` (`marap`, `maqh`, `tenrap`, `daichi`, `sodt`, `soluongphong`, `giomo`, `giodong`, `mota`, `hinh_anh`) VALUES
(1, 1, 'Lotte Cinema Hà Đông', 'Tầng 4 Mê Linh Plaza, Tô Hiệu, Hà Đông, Hà Nội\r\n', '0302575928', 7, NULL, NULL, 'Tất cả phòng chiếu phim Lotte Cinema được đầu tư công nghệ tiên tiến và hiện đại bậc nhất cùng thiết kế sang trọng và tinh tế. Với mong muốn mang lại những trải nghiệm điện ảnh sống động, chân thật cùng những giây phút thư giãn bên gia đình, bạn bè và người thân cho quý khách hàng. Hệ thống rạp chiếu phim Lotte Cinema Việt Nam luôn nỗ lực nhằm phát triển chất lượng dịch vụ mang đẳng cấp quốc tế với mức giá ưu đãi.', 'sources/img/lotte_cinema.jpg'),
(2, 2, 'Rạp chiếu phim Platinum', 'Tầng 4, Tòa nhà The Garden, Mễ Trì, Từ Liêm, Hà Nội, Việt Nam\r\n', '02437878555', 6, NULL, NULL, 'Vì ở khá xa trung tâm thành phố. Nên rạp chiếu phim Platinum Cineplex The Garden, không đông đúc nhộn nhịp như những địa điểm xem phim ở Hà Nội khác. Đến xem phim ở đây bạn sẽ được tận hưởng không khí nhẹ nhàng và yên tĩnh vì rạp hiếm khi full chỗ.\r\n\r\nTuy nhiên với các loạt phim hot và phim bom tấn. Chuyện hết chỗ sớm cũng rất bình thường vì rạp có một lượng khách quen đông đảo luôn ủng hộ.\r\n\r\n', 'sources/img/platiumcineplex.jpg'),
(3, 5, 'Beta Cineplex Thanh Xuân', 'Tầng hầm B1, tòa Golden West, số 2 Lê Văn Thiêm, P. Nhân Chính, Q. Thanh Xuân, Hà Nội.', '0869 133 540', 6, NULL, NULL, 'Beta Media được thành lập với mục tiêu đem tới khách hàng các sản phẩm và dịch vụ chất lượng tốt nhất. Cùng với đó là giá cả hợp lý. Với hai mảng kinh doanh chính là Tổ hợp dịch vụ ăn uống giải trí và cung cấp dịch vụ truyền thông.', 'sources/img/beta_cineplex.jpg'),
(4, 4, 'CGV Times City', 'Tầng B1, TTTM Vincom Mega Mall Times City, 458 Minh Khai, Hai Bà Trưng, Hà Nội', '1900 6017', 5, NULL, NULL, 'Đặc biệt, CGV có phong cách decor rất hiện đại và thời trang. Chính vì thế đây cũng là một trong những địa điểm sống ảo Hà Nội yêu thích của giới trẻ. Không chỉ có vậy, mỗi bộ phim bom tấn công chiếu, cgv sẽ có bán những phụ kiện như cốc uống nước,… thu hút các vị khách phải săn lùng về tay. Phải nói rằng CGV rất am hiểu thị hiếu của giới trẻ Hà Nội.', 'sources/img/cgv.jpg'),
(5, 3, 'BHD Vincom Phạm Ngọc Thạch', 'Tầng 8 Vincom Center, 2 Phạm Ngọc Thạch, Kim Liên, Đống Đa, Hà Nội', '19002099', 7, NULL, NULL, 'BHD Star là rạp chiếu phim mới được xây dựng và khai trương cùng đợt với Vincom Phạm Ngọc Thạch. Rạp ở tầng 8 của trung tâm, nếu bạn gửi xe dưới hầm sẽ có thang máy dẫn thẳng lên đó.\r\nKhông gian trang trí của rạp rất đẹp, trên các tưởng được vẽ thiết kế 3D khá bắt mắt. Kết hợp với không gian, bàn ghế bên cạnh tạo một nơi khá là tuyệt vời cho nhiều bạn trẻ muốn check in.\r\n\r\n', 'sources/img/bhd_pnt.jpg'),
(6, 6, 'Lotte Cinema Thăng Long', 'Tầng 3 Big C Thăng Long, 222 Trần Duy Hưng, Q Cầu Giấy, Tp. Hà Nội', '02439454999 ', 4, NULL, NULL, 'Tất cả phòng chiếu phim Lotte Cinema được đầu tư công nghệ tiên tiến và hiện đại bậc nhất cùng thiết kế sang trọng và tinh tế. Với mong muốn mang lại những trải nghiệm điện ảnh sống động, chân thật cùng những giây phút thư giãn bên gia đình, bạn bè và người thân cho quý khách hàng. Hệ thống rạp chiếu phim Lotte Cinema Việt Nam luôn nỗ lực nhằm phát triển chất lượng dịch vụ mang đẳng cấp quốc tế với mức giá ưu đãi.', 'sources/img/lotte_cinema.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `rap_khuyen_mai`
--

CREATE TABLE `rap_khuyen_mai` (
  `marap` int NOT NULL,
  `makm` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `rap_khuyen_mai`
--

INSERT INTO `rap_khuyen_mai` (`marap`, `makm`) VALUES
(6, 3),
(6, 4),
(1, 5),
(5, 5);

-- --------------------------------------------------------

--
-- Table structure for table `suat_chieu`
--

CREATE TABLE `suat_chieu` (
  `masuatchieu` int NOT NULL,
  `ngaychieu` date DEFAULT NULL,
  `makhunggio` int NOT NULL,
  `maphim` int NOT NULL,
  `marap` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `suat_chieu`
--

INSERT INTO `suat_chieu` (`masuatchieu`, `ngaychieu`, `makhunggio`, `maphim`, `marap`) VALUES
(1, '2020-12-12', 1, 4, 3),
(2, '2020-12-10', 5, 1, 5),
(4, '2020-12-21', 1, 5, 3),
(5, '2020-12-21', 2, 2, 6),
(6, '2020-12-23', 3, 16, 4),
(7, '2020-12-24', 5, 15, 2),
(8, '2020-12-25', 5, 14, 5),
(9, '2020-12-20', 1, 6, 1),
(10, '2020-12-27', 2, 3, 3),
(11, '2020-12-28', 5, 7, 3),
(12, '2020-12-24', 1, 1, 2),
(13, '2020-12-24', 1, 1, 1),
(14, '2020-12-24', 1, 1, 3),
(15, '2020-12-24', 1, 1, 4),
(16, '2020-12-24', 1, 1, 6),
(17, '2020-12-21', 2, 2, 1),
(18, '2020-12-21', 2, 2, 2),
(19, '2020-12-21', 2, 2, 3),
(20, '2020-12-21', 2, 2, 4),
(21, '2020-12-21', 3, 2, 5),
(22, '2020-12-20', 2, 3, 1),
(23, '2020-12-20', 3, 3, 2),
(24, '2020-12-20', 5, 3, 4),
(25, '2020-12-20', 4, 3, 5),
(26, '2020-12-20', 3, 3, 6),
(27, '2020-12-20', 2, 4, 1),
(28, '2020-12-20', 3, 4, 2),
(29, '2020-12-20', 4, 4, 4),
(30, '2020-12-20', 4, 4, 5),
(31, '2020-12-20', 6, 4, 6),
(32, '2020-12-20', 5, 5, 1),
(33, '2020-12-20', 6, 5, 2),
(34, '2020-12-20', 4, 5, 4),
(35, '2020-12-22', 4, 5, 5),
(36, '2020-12-22', 5, 5, 6);

--
-- Triggers `suat_chieu`
--
DELIMITER $$
CREATE TRIGGER `kt_suat_chieu` AFTER INSERT ON `suat_chieu` FOR EACH ROW BEGIN
	DECLARE khoi_chieu DATE;
    SET khoi_chieu = (select p.batdau from phim as p
    	where p.maphim = new.maphim
    );
    IF new.ngaychieu < khoi_chieu THEN
    	delete from suat_chieu where suat_chieu.masuatchieu = new.masuatchieu;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `su_dung_dich_vu`
--

CREATE TABLE `su_dung_dich_vu` (
  `mahoadon` int NOT NULL,
  `madv` int NOT NULL,
  `soluong` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `the_loai`
--

CREATE TABLE `the_loai` (
  `maphim` int NOT NULL,
  `theloai` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `the_loai`
--

INSERT INTO `the_loai` (`maphim`, `theloai`) VALUES
(1, 'Hành động'),
(2, 'Hành động'),
(2, 'Phiêu lưu'),
(3, 'Hành động'),
(3, 'Phiêu lưu'),
(4, 'Hài'),
(5, 'Tình cảm'),
(6, 'Hài'),
(6, 'Tình cảm'),
(7, 'Gia đình'),
(7, 'Hoạt hình'),
(8, 'Hành động'),
(8, 'Tội phạm'),
(9, 'Hài'),
(9, 'Tâm lý'),
(10, 'Hành động'),
(10, 'Phiêu lưu'),
(11, 'Hoạt hình'),
(11, 'Phiêu lưu'),
(12, 'Hành Động'),
(12, 'Phiêu lưu'),
(13, 'Hoạt hình'),
(14, 'Hoạt hình'),
(14, 'Phiêu lưu'),
(15, 'Hành động'),
(15, 'Tội phạm'),
(16, 'Hành động'),
(16, 'Kinh dị'),
(17, 'Hành động'),
(17, 'Phiêu lưu'),
(18, 'Hoạt hình'),
(19, 'Hành động'),
(19, 'Hoạt hình'),
(20, 'Kinh dị'),
(20, 'Tâm lý');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(400) NOT NULL,
  `ngaysinh` date DEFAULT NULL,
  `gioitinh` tinyint(1) DEFAULT NULL,
  `sodt` varchar(20) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `cmnd` varchar(10) DEFAULT NULL,
  `updated_at` date DEFAULT NULL,
  `created_at` date DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `ngaysinh`, `gioitinh`, `sodt`, `name`, `cmnd`, `updated_at`, `created_at`, `remember_token`) VALUES
(1, 'nhuttan@gmail.com', '$2y$10$o5UvIFDtH6AKI4pkDmCB7ujy/TuiXYxIntTm2Ogkao6rcrMUVq2ki', '1998-03-08', 1, '0168425933', 'Trần Nhựt Tân', '321456987', NULL, NULL, NULL),
(2, 'tiencuong@gmail.com', '$2y$10$gsdlb8/GMwqfEB1fI67QdeUugmw0s6OK28rw2xcOhe.p.0HRH9Di6', '1997-09-12', 1, '0125866977', 'Văn Tiến Cường', '312569874', NULL, NULL, NULL),
(3, 'nhuy@gmail.com', '$2y$10$TtXjr6v0fhFe2X/.ejOgwenkX5XQT5o6Q.mbFJ0fbUB3jM6a3Zk6.', '1995-08-15', 0, '0147569823', 'Nguyễn Thị Như Ý', '326587419', NULL, NULL, 'bT48u9iZme4XUBoScWV218Ta2HizcYb6e9UdVeB5fISRkWKXLuMPdQW2PRq4'),
(4, 'ducmanh@gmail.com', '$2y$10$TU5ejPQa2HAhYtXLIGFqqOwOoLstZKsab85dNNQ3G3ZqGszjfUvLS', '1995-11-12', 1, '0169852365', 'Lê Đức Mạnh', '312478555', NULL, NULL, NULL),
(5, 'thaiminh@gmail.com', '$2y$10$tejW2ECYmRUIpTHwHodMLOuI/YfSzqNdrpjHkscppDtYXi6.JAZ6O', '1990-06-01', 0, '0125866347', 'Trương Thị Thái Minh', '325144696', NULL, NULL, NULL),
(6, 'thuyhang@gmail.com', '$2y$10$KPXjQ5MMUEveGeLeV3uOzuyjNAtE7lLMWTQIN6DFytIIdyoomeTBC', '1999-04-30', 0, '0153698742', 'Lê Thúy Hằng', '312546985', NULL, NULL, NULL),
(7, 'tuankiet@gmail.com', '$2y$10$UMnI4Rthvurj0JHxYuK1VehKWmUc3/P/5V18p9E0G93GpDzbbpbme', '1998-04-30', 1, '0121355655', 'Lương Tuấn Kiệt', '312564888', NULL, NULL, NULL),
(8, 'nguyenbinh@gmail.com', '$2y$10$DuoDrdHKQHbZJ9HeF4LLoOMdkUfLPW9PQYFoOAaFplMeICM9HJe4u', '1998-01-20', 1, '01678424666', 'Cao Nguyên Bình', '312346384', '2020-10-30', '2020-10-26', 'QLfQhv2loUwyg5yq0BPMLJ0XxzVmzDXERg8DskPEv6ZZTTnDdz5tpAaueC9j'),
(9, 'quocanh@gmail.com', '$2y$10$319cX6srrT3Vbp58hKCRvuxPbROTcg8a7WObzs7uQerX6bqq33bIC', '1996-02-29', 1, '01218003162', 'Nguyễn Quốc Anh', '31256841', NULL, NULL, 'BoJ1C5qCaJbE1xVyrGBP8NjUypR2pcQpX3K1Tb0y8cnlOAhcZnZn5hZRfzDS'),
(10, 'hoangnguyen@gmail.com', '$2y$10$UgfteDJ1NZSqh1AXjCDmK.lpVP1xBIBs2o6hfJJCZiNU/LWevkqnO', '1995-03-08', 0, '0902303802', 'Thái Hoàng Nguyên', '32569147', '2020-10-30', '2020-10-26', NULL),
(11, 'bangbang@gmail.com', '$2y$10$x7cYlcKjVFs8w2v1zgzEGuV6apXyNJE6Pr26Cr6Ntfxkl5PxgLdAq', '1995-03-08', 0, '0902303802', 'Phạm Băng Băng', '32569147', NULL, NULL, NULL),
(12, 'xuanhuy@gmail.com', '$2y$10$RXoegCXQKBHeTjlMs/N6zejpGAyOP6IdflPcn9FYIHe2kYF7Z.n4a', '1998-11-20', 1, '0167425983', 'Nguyễn Xuân Huy', '312459876', NULL, NULL, NULL),
(13, 'thanhduy@gmail.com', '$2y$10$O7Kr31ps6u361PHXligJOe.vmBA0V2FXm3zUHe3xO.p1bzjnX1rdy', '1998-12-01', 1, '0121369875', 'Nguyễn Thàn Duy', '325698741', NULL, NULL, NULL),
(14, 'hiepbkcntt@gmail.com', '$2y$10$0pD4pi9zcZEj.OVZJnKxpeg.9eeB10VryjXF1yEkESr.SbzxY2WYS', '1999-01-11', 1, '0399685122', 'Nguyen Manh Hiep', '123456789', '2020-10-30', '2020-10-30', 'yKixj6gQpfWHqS4OWLamGyBq5mtrixKTiE3V4lLwec7p0iKTrCo6jz8hkDeZ'),
(15, 'hadm@gmail.com', '$2y$10$ADRFO.vSV1KqRDjvWl05MOz4OjqQclL6t.x8Mo.6W286G/fmiRQEK', '1999-02-01', 1, '0399005122', 'Do Manh Ha', '098765432', '2020-12-11', '2020-12-11', NULL),
(16, 'anhnd@gmail.com', '$2y$10$h4ot2zhGFjqUBxHpaRXG2.FszFfufwaurcqLwh3UzoZsn/84NIOty', '1999-02-04', 1, '0399685169', 'nguyen duc anh', '456298471', '2020-12-11', '2020-12-11', NULL),
(17, 'anhnd1@gmail.com', '$2y$10$zzvnFJBFav3RBoigUx9hs.4jE20VSdxyti6pmtx6iLx0GNdUiSqBS', '1999-02-04', 1, '0399685168', 'nguyen duc anh', '456298472', '2020-12-11', '2020-12-11', 'bdHz0c6WBEiJmBSeLLQFBdZ2MOmVPcob9UpcHnwIvcVfyI1Hvg7VzIyfoo9q'),
(18, 'hiep.nm176750@sis.hust.edu.vn', '$2y$10$xM13z.inCFInp15Y7eym.Odnyh3XA3zUjn4VMbCCHVS84W7bcuceK', '1999-01-11', 1, '0399685128', 'Nguyen Manh Hiep', '099999999', '2020-12-11', '2020-12-11', NULL),
(19, 'quangnd@gmail.com', '$2y$10$LSqd9dc9bw1GlkeD5FZvS.ZPNw4dSVzpLMeSoUgGsq3mUbXPAzjwe', '1999-01-03', 1, '0974726869', 'Quang Nguyen', '013626151', '2020-12-12', '2020-12-12', 'GdGqLjUnhqNqjym6c1SI9P7nW29YVvAS4yPjGe8mfg0GqXwEKhPOz6vBWxEn'),
(20, 'hhqcinema@gmail.com', '$2y$10$LSqd9dc9bw1GlkeD5FZvS.ZPNw4dSVzpLMeSoUgGsq3mUbXPAzjwe', '1999-12-14', 1, '0344982572', 'HHQCinema', '152222222', '2020-12-16', '2020-12-16', 'hVlHcxyYfysSVYNCOGD52YJ46U3okwzLEO9k0vfZ0ApEnmuJREQJ6bTga2TM');

-- --------------------------------------------------------

--
-- Table structure for table `ve`
--

CREATE TABLE `ve` (
  `ngayxuat` date DEFAULT NULL,
  `mave` int NOT NULL,
  `masuatchieu` int NOT NULL,
  `maghe` int NOT NULL,
  `mahoadon` int NOT NULL,
  `updated_at` date DEFAULT NULL,
  `created_at` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ve`
--

INSERT INTO `ve` (`ngayxuat`, `mave`, `masuatchieu`, `maghe`, `mahoadon`, `updated_at`, `created_at`) VALUES
('2020-11-06', 21, 2, 1745, 7, '2020-11-06', '2020-11-06'),
('2020-11-06', 23, 2, 1744, 12, '2020-11-06', '2020-11-06'),
('2020-12-04', 24, 11, 1025, 13, '2020-12-04', '2020-12-04'),
('2020-12-04', 25, 11, 1026, 14, '2020-12-04', '2020-12-04'),
('2020-12-06', 26, 11, 1036, 15, '2020-12-06', '2020-12-06'),
('2020-12-06', 27, 11, 1040, 16, '2020-12-06', '2020-12-06'),
('2020-12-06', 28, 11, 1050, 16, '2020-12-06', '2020-12-06'),
('2020-12-11', 29, 9, 317, 60, '2020-12-11', '2020-12-11'),
('2020-12-11', 30, 9, 317, 60, '2020-12-11', '2020-12-11'),
('2020-12-11', 31, 9, 294, 62, '2020-12-11', '2020-12-11'),
('2020-12-12', 32, 9, 319, 63, '2020-12-12', '2020-12-12'),
('2020-12-12', 33, 9, 366, 64, '2020-12-12', '2020-12-12'),
('2020-12-12', 34, 9, 211, 65, '2020-12-12', '2020-12-12'),
('2020-12-12', 35, 24, 1505, 66, '2020-12-12', '2020-12-12');

--
-- Triggers `ve`
--
DELIMITER $$
CREATE TRIGGER `kt_nhatquan_rapchieu` AFTER INSERT ON `ve` FOR EACH ROW BEGIN
	declare marap_ve, marap_sc int;
	set marap_ve = (select gn.marap from ghe_ngoi as gn
    	where gn.maghe = new.maghe
    );
	select sc.marap from suat_chieu as sc
		where sc.masuatchieu = new.masuatchieu into marap_sc;
	IF marap_ve <> marap_sc
    THEN
    	DELETE FROM ve where ve.mave = new.mave;
    END IF;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `dia_ban`
--
ALTER TABLE `dia_ban`
  ADD PRIMARY KEY (`maqh`);

--
-- Indexes for table `dich_vu`
--
ALTER TABLE `dich_vu`
  ADD PRIMARY KEY (`madv`);

--
-- Indexes for table `dien_vien`
--
ALTER TABLE `dien_vien`
  ADD PRIMARY KEY (`maphim`,`dienvien`);

--
-- Indexes for table `ghe_ngoi`
--
ALTER TABLE `ghe_ngoi`
  ADD PRIMARY KEY (`maghe`),
  ADD KEY `tenloai` (`tenloai`),
  ADD KEY `maphong` (`maphong`),
  ADD KEY `marap` (`marap`);

--
-- Indexes for table `hoa_don`
--
ALTER TABLE `hoa_don`
  ADD PRIMARY KEY (`mahoadon`),
  ADD KEY `matk_kh` (`idkh`),
  ADD KEY `matk_nv` (`idnv`);

--
-- Indexes for table `hoa_don_khuyen_mai`
--
ALTER TABLE `hoa_don_khuyen_mai`
  ADD PRIMARY KEY (`mahoadon`),
  ADD KEY `makm` (`makm`) USING BTREE;

--
-- Indexes for table `khach_hang`
--
ALTER TABLE `khach_hang`
  ADD PRIMARY KEY (`idkh`);

--
-- Indexes for table `khung_gio`
--
ALTER TABLE `khung_gio`
  ADD PRIMARY KEY (`makhunggio`);

--
-- Indexes for table `khuyen_mai`
--
ALTER TABLE `khuyen_mai`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `loai_ghe`
--
ALTER TABLE `loai_ghe`
  ADD PRIMARY KEY (`tenloai`);

--
-- Indexes for table `loai_phong`
--
ALTER TABLE `loai_phong`
  ADD PRIMARY KEY (`tenloai`) USING BTREE;

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `nhan_vien`
--
ALTER TABLE `nhan_vien`
  ADD PRIMARY KEY (`idnv`),
  ADD KEY `matk_quanly` (`idquanly`),
  ADD KEY `marap` (`marap`);

--
-- Indexes for table `phim`
--
ALTER TABLE `phim`
  ADD PRIMARY KEY (`maphim`);

--
-- Indexes for table `phong_chieu`
--
ALTER TABLE `phong_chieu`
  ADD PRIMARY KEY (`maphong`,`marap`),
  ADD KEY `tenloaiphong` (`tenloai`),
  ADD KEY `marap` (`marap`);

--
-- Indexes for table `rap_chieu`
--
ALTER TABLE `rap_chieu`
  ADD PRIMARY KEY (`marap`),
  ADD KEY `maqh` (`maqh`);

--
-- Indexes for table `rap_khuyen_mai`
--
ALTER TABLE `rap_khuyen_mai`
  ADD PRIMARY KEY (`marap`,`makm`),
  ADD KEY `makm` (`makm`);

--
-- Indexes for table `suat_chieu`
--
ALTER TABLE `suat_chieu`
  ADD PRIMARY KEY (`masuatchieu`),
  ADD KEY `makhunggio` (`makhunggio`),
  ADD KEY `maphim` (`maphim`),
  ADD KEY `marap` (`marap`);

--
-- Indexes for table `su_dung_dich_vu`
--
ALTER TABLE `su_dung_dich_vu`
  ADD PRIMARY KEY (`mahoadon`,`madv`),
  ADD KEY `su_dung_dich_vu_ibfk_1` (`madv`);

--
-- Indexes for table `the_loai`
--
ALTER TABLE `the_loai`
  ADD PRIMARY KEY (`maphim`,`theloai`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ve`
--
ALTER TABLE `ve`
  ADD PRIMARY KEY (`mave`),
  ADD KEY `masuatchieu` (`masuatchieu`),
  ADD KEY `maghe` (`maghe`),
  ADD KEY `mahoadon` (`mahoadon`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `dia_ban`
--
ALTER TABLE `dia_ban`
  MODIFY `maqh` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `dich_vu`
--
ALTER TABLE `dich_vu`
  MODIFY `madv` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `ghe_ngoi`
--
ALTER TABLE `ghe_ngoi`
  MODIFY `maghe` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2532;

--
-- AUTO_INCREMENT for table `hoa_don`
--
ALTER TABLE `hoa_don`
  MODIFY `mahoadon` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT for table `khung_gio`
--
ALTER TABLE `khung_gio`
  MODIFY `makhunggio` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `khuyen_mai`
--
ALTER TABLE `khuyen_mai`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `phim`
--
ALTER TABLE `phim`
  MODIFY `maphim` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `phong_chieu`
--
ALTER TABLE `phong_chieu`
  MODIFY `maphong` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT for table `rap_chieu`
--
ALTER TABLE `rap_chieu`
  MODIFY `marap` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `suat_chieu`
--
ALTER TABLE `suat_chieu`
  MODIFY `masuatchieu` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `ve`
--
ALTER TABLE `ve`
  MODIFY `mave` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `dien_vien`
--
ALTER TABLE `dien_vien`
  ADD CONSTRAINT `dien_vien_ibfk_1` FOREIGN KEY (`maphim`) REFERENCES `phim` (`maphim`);

--
-- Constraints for table `ghe_ngoi`
--
ALTER TABLE `ghe_ngoi`
  ADD CONSTRAINT `ghe_ngoi_ibfk_1` FOREIGN KEY (`maphong`) REFERENCES `phong_chieu` (`maphong`),
  ADD CONSTRAINT `ghe_ngoi_ibfk_2` FOREIGN KEY (`marap`) REFERENCES `phong_chieu` (`marap`),
  ADD CONSTRAINT `ghe_ngoi_ibfk_3` FOREIGN KEY (`tenloai`) REFERENCES `loai_ghe` (`tenloai`);

--
-- Constraints for table `hoa_don`
--
ALTER TABLE `hoa_don`
  ADD CONSTRAINT `hoa_don_ibfk_2` FOREIGN KEY (`idnv`) REFERENCES `nhan_vien` (`idnv`) ON DELETE SET NULL,
  ADD CONSTRAINT `hoa_don_ibfk_3` FOREIGN KEY (`idkh`) REFERENCES `khach_hang` (`idkh`) ON DELETE SET NULL;

--
-- Constraints for table `hoa_don_khuyen_mai`
--
ALTER TABLE `hoa_don_khuyen_mai`
  ADD CONSTRAINT `hoa_don_khuyen_mai_ibfk_1` FOREIGN KEY (`makm`) REFERENCES `khuyen_mai` (`id`),
  ADD CONSTRAINT `hoa_don_khuyen_mai_ibfk_2` FOREIGN KEY (`mahoadon`) REFERENCES `hoa_don` (`mahoadon`) ON DELETE CASCADE;

--
-- Constraints for table `khach_hang`
--
ALTER TABLE `khach_hang`
  ADD CONSTRAINT `khach_hang_ibfk_1` FOREIGN KEY (`idkh`) REFERENCES `users` (`id`);

--
-- Constraints for table `nhan_vien`
--
ALTER TABLE `nhan_vien`
  ADD CONSTRAINT `nhan_vien_ibfk_1` FOREIGN KEY (`idnv`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `nhan_vien_ibfk_2` FOREIGN KEY (`idquanly`) REFERENCES `nhan_vien` (`idnv`),
  ADD CONSTRAINT `nhan_vien_ibfk_3` FOREIGN KEY (`marap`) REFERENCES `rap_chieu` (`marap`);

--
-- Constraints for table `phong_chieu`
--
ALTER TABLE `phong_chieu`
  ADD CONSTRAINT `phong_chieu_ibfk_1` FOREIGN KEY (`marap`) REFERENCES `rap_chieu` (`marap`),
  ADD CONSTRAINT `phong_chieu_ibfk_2` FOREIGN KEY (`tenloai`) REFERENCES `loai_phong` (`tenloai`);

--
-- Constraints for table `rap_chieu`
--
ALTER TABLE `rap_chieu`
  ADD CONSTRAINT `rap_chieu_ibfk_1` FOREIGN KEY (`maqh`) REFERENCES `dia_ban` (`maqh`);

--
-- Constraints for table `rap_khuyen_mai`
--
ALTER TABLE `rap_khuyen_mai`
  ADD CONSTRAINT `rap_khuyen_mai_ibfk_1` FOREIGN KEY (`marap`) REFERENCES `rap_chieu` (`marap`),
  ADD CONSTRAINT `rap_khuyen_mai_ibfk_2` FOREIGN KEY (`makm`) REFERENCES `khuyen_mai` (`id`);

--
-- Constraints for table `suat_chieu`
--
ALTER TABLE `suat_chieu`
  ADD CONSTRAINT `suat_chieu_ibfk_1` FOREIGN KEY (`makhunggio`) REFERENCES `khung_gio` (`makhunggio`),
  ADD CONSTRAINT `suat_chieu_ibfk_2` FOREIGN KEY (`maphim`) REFERENCES `phim` (`maphim`),
  ADD CONSTRAINT `suat_chieu_ibfk_3` FOREIGN KEY (`marap`) REFERENCES `rap_chieu` (`marap`);

--
-- Constraints for table `su_dung_dich_vu`
--
ALTER TABLE `su_dung_dich_vu`
  ADD CONSTRAINT `su_dung_dich_vu_ibfk_1` FOREIGN KEY (`madv`) REFERENCES `dich_vu` (`madv`) ON UPDATE CASCADE,
  ADD CONSTRAINT `su_dung_dich_vu_ibfk_2` FOREIGN KEY (`mahoadon`) REFERENCES `hoa_don` (`mahoadon`);

--
-- Constraints for table `the_loai`
--
ALTER TABLE `the_loai`
  ADD CONSTRAINT `the_loai_ibfk_1` FOREIGN KEY (`maphim`) REFERENCES `phim` (`maphim`);

--
-- Constraints for table `ve`
--
ALTER TABLE `ve`
  ADD CONSTRAINT `ve_ibfk_1` FOREIGN KEY (`masuatchieu`) REFERENCES `suat_chieu` (`masuatchieu`),
  ADD CONSTRAINT `ve_ibfk_2` FOREIGN KEY (`maghe`) REFERENCES `ghe_ngoi` (`maghe`),
  ADD CONSTRAINT `ve_ibfk_3` FOREIGN KEY (`mahoadon`) REFERENCES `hoa_don` (`mahoadon`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
