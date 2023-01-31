--Genel bak��
SELECT * 
FROM ibb.dbo.deprem
SELECT * 
FROM ibb.dbo.bina



--Join i�lemi
-- iki tabloda da id kolonunu primary key se�erek import etmi�tim
-- mahalle_koy_uavt ve mahalle_uavt kolonlar� ise il�elerin ulusal adreslerini i�eriyor ve
-- iki tabloda da ortak
SELECT * 
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt



--Tek de�i�kenli inceleme
SELECT *
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
--ORDER BY cok_agir_hasarli_bina_sayisi DESC
--ORDER BY agir_hasarli_bina_sayisi DESC
--ORDER BY orta_hasarli_bina_sayisi DESC
--ORDER BY hafif_hasarli_bina_sayisi DESC
ORDER BY can_kaybi_sayisi DESC



-- Hi� can kayb� olmayan b�lgeler? �l�e-mahalle baz�nda
SELECT d.ilce_adi,d.mahalle_adi,d.can_kaybi_sayisi
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b
ON d.mahalle_koy_uavt = b.mahalle_uavt
WHERE can_kaybi_sayisi = 0

-- Hi� bir mahallesinde bile can kayb� olmayan, tamam�nda can kayb� ya�anmayan il�eler?

SELECT d.ilce_adi,SUM(d.can_kaybi_sayisi) AS �lceTopCanKaybi
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
HAVING SUM(d.can_kaybi_sayisi) = 0		---- ARNAVUTK�Y VE ��LE il�elerinin H�� B�R mahallesinde can kayb�
										--  ya�anmam��, bu kriter bak�m�ndan en g�venli il�eler oldu�u s�ylenebilir.






--Tek de�i�kenli inceleme, il�e baz�nda gruplu
SELECT d.ilce_adi, 
SUM(cok_agir_hasarli_bina_sayisi) AS �lceTopCokAgirHasar,
SUM(agir_hasarli_bina_sayisi) AS �lceTopAgirHasar,
SUM(orta_hasarli_bina_sayisi) AS �lceTopOrtaHasar,
SUM(hafif_hasarli_bina_sayisi) AS �lceTopHafifHasar,
SUM(can_kaybi_sayisi) AS �lceTopCanKaybi,
SUM(gecici_barinma) AS �lceTopSiginak
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
--ORDER BY �lceTopCokAgirHasar DESC -- FAT�H, K���K�EKMECE, BA�CILAR, BAH�EL�EVLER, BAKIRK�Y...
--ORDER BY �lceTopAgirHasar DESC -- FAT�H, K���K�EKMECE, BA�CILAR, ESENYURT, S�L�VR�...
--ORDER BY �lceTopOrtaHasar DESC -- FAT�H, K���K�EKMECE, BA�CILAR, ESENYURT, S�L�VR�...
--ORDER BY �lceTopHafifHasar DESC -- FAT�H, BA�CILAR, ESENYURT, K���K�EKMECE, PEND�K...
--ORDER BY �lceTopCanKaybi DESC -- BAH�EL�EVLER, K���K�EKMECE, FAT�H, BA�CILAR, BAKIRK�Y...
ORDER BY �lceTopSiginak DESC -- K���K�EKMECE, ESENYURT, BAH�EL�EVLER, BA�CILAR, FAT�H...
								
								-- Olas� deprem senaryosunda en �ok can kayb� ya�ayacak ve hasar alacak b�lgelerin
								-- FAT�H, K���K�EKMECE, BA�CILAR, BAH�EL�EVLER olaca�� s�ylenebilir.


--------------------	�ki de�i�kenli inceleme

------�l�e ve mahalle baz�nda; toplamda ne kadar bina hasar g�rm��?
SELECT d.ilce_adi,d.mahalle_adi, 
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)
as ToplamHasarliBina
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
ORDER BY ToplamHasarliBina DESC --Olas� deprem senaryosunda en �ok hasar alacak binaya sahip il�e ve mahalleler ilk be�:
								-- AVCILAR - YE��LKENT
								-- K���K�EKMECE - �N�N�
								-- BAH�EL�EVLER - ZAFER
								-- S�L�VR� - SEM�ZKUMLAR
								-- TUZLA - AYDINLI




--
--Toplam bina say�lar� ve toplam hasarl� bina say�lar�n� kar��la�t�rmadan �nce CTE olu�turaca��m
--�l�e ve mahalle baz�nda;
--1) Toplam binalar�n y�zde ka�� hasarl�? 
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,
(ToplamHasarliBina*1.0 / ToplamBina)*100 AS HasarliBinaOrani
FROM BinaOranlari
ORDER BY HasarliBinaOrani DESC  --Olas� deprem senaryosunda en �ok (hasarl� bina/toplam bina) oran�na sahip olacak
								--il�e ve mahalleler ilk be�:
								-- BAKIRK�Y - YE��LYURT				%83 oranda hasarl� bina
								-- BAKIRK�Y - SAKIZA�ACI			%82 oranda hasarl� bina
								-- FAT�H - YED�KULE					%82 oranda hasarl� bina
								-- BAKIRK�Y - YEN�MAHALLE			%81 oranda hasarl� bina
								-- BAKIRK�Y - ATAK�Y 3-4-11. KISIM	%81 oranda hasarl� bina




--2) Ayn� oranlar� il�e baz�nda gruplama
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,HasarliBinaOrani)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina,
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)*1.0
/
(_1980_oncesi+_1980_2000_arasi+_2000_sonrasi)*100 AS HasarliBinaOrani
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT ilce_adi,SUM(ToplamHasarliBina) AS �lceToplamHasarliBina,SUM(ToplamBina) AS �lceToplamBina,
(SUM(ToplamHasarliBina)*1.0/SUM(ToplamBina))*100 AS �lceHasarOrani
FROM BinaOranlari
GROUP BY ilce_adi
ORDER BY �lceHasarOrani DESC --En �ok hasar alan il�eler
							 --olas� bir deprem senaryosunda en �ok hasar alacak ilk 5 il�e:
							 --BAKIRK�Y %78 oranla hasarl�
							 --ADALAR %76 oranla hasarl�
							 --BAH�EL�EVLER %75 oranla hasarl�
							 --ZEYT�NBURNU %72 oranla hasarl�
							 --G�NG�REN %72 oranla hasarl�




------ Binalar�n ya�lar� binalar�n alaca�� hasar� ne kadar etkiliyor?

--1) 1980den eski binalar�n �o�unluk oldu�u il�e ve mahallelerde hasar oranlar� nas�l?
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,HasarliBinaOrani,_1980OncesiOrani)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina,
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)*1.0
/
(_1980_oncesi+_1980_2000_arasi+_2000_sonrasi)*100 AS HasarliBinaOrani,
_1980_oncesi*1.0 / (_1980_oncesi+_1980_2000_arasi+_2000_sonrasi +0.0000001)*100 AS _1980OncesiOrani
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina, HasarliBinaOrani,_1980OncesiOrani
FROM BinaOranlari
ORDER BY _1980OncesiOrani DESC
							   -- Eski binalar�n �o�unlukta olmas� al�nacak hasar� kesin bir �ekilde art�r�r
							   -- demek do�ru olmayabilir. �rne�in BEYO�LU - �UKUR b�lgesindeki binalar�n
							   -- %84� 1980 �ncesinden kalma olmas�na ra�men %35 hasar oran�na sahip,
							   -- tam tersi olarak 1980 �ncesinden kalma yap�land�rma bulundurmamas�na ra�men
							   -- %70lerde bile hasar oran� olan b�lgeler bulunmakta.


--2) 2000 ve sonras�nda yap�lan binalar�n �o�unlukta oldu�u b�lgelerde durum nas�l?

--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,HasarliBinaOrani,_1980OncesiOrani,_2000SonrasiOrani)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina,
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)*1.0
/
(_1980_oncesi+_1980_2000_arasi+_2000_sonrasi)*100 AS HasarliBinaOrani,
_1980_oncesi*1.0 / (_1980_oncesi+_1980_2000_arasi+_2000_sonrasi +0.0000001)*100 AS _1980OncesiOrani,
_2000_sonrasi*1.0 / (_1980_oncesi+_1980_2000_arasi+_2000_sonrasi +0.0000001)*100 AS _2000SonrasiOrani
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT ilce_adi, mahalle_adi, ToplamHasarliBina, ToplamBina, HasarliBinaOrani, _1980OncesiOrani, _2000SonrasiOrani
FROM BinaOranlari
ORDER BY _2000SonrasiOrani DESC		-- Daha yeni binalar�n �o�unlukta oldu�u b�lgelerde net bir �ekilde hasar�n 
									-- az oldu�unu s�ylemek do�ru de�il, benzer �ekilde farkl� �rnekler bulunmakta.





-- Tam olarak kar��la�t�rma yapabilmek i�in hasar�n t�r� de �nemli, ayn� eski-yeni oranlar�n� binalardaki hasar�n �iddeti ile kar��la�t�rmak gerekli
-- Eski binalar i�in
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,CokHasarliBinaOrani,AgirHasarliBinaOrani,OrtaHasarliBinaOrani,HafifHasarliBinaOrani,HasarliBinaOrani,_1980OncesiOrani,_2000SonrasiOrani)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina,

cok_agir_hasarli_bina_sayisi*1.0/ (cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi+0.0000001)*100 AS CokHasarliBinaOrani,
agir_hasarli_bina_sayisi*1.0/ (cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi+0.0000001)*100 AS AgirHasarliBinaOrani,
orta_hasarli_bina_sayisi*1.0/ (cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi+0.0000001)*100 AS OrtaHasarliBinaOrani,
hafif_hasarli_bina_sayisi*1.0/ (cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi+0.0000001)*100 AS HafifHasarliBinaOrani,

(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)*1.0
/
(_1980_oncesi+_1980_2000_arasi+_2000_sonrasi+0.0000001)*100 AS HasarliBinaOrani,
_1980_oncesi*1.0 / (_1980_oncesi+_1980_2000_arasi+_2000_sonrasi +0.0000001)*100 AS _1980OncesiOrani,
_2000_sonrasi*1.0 / (_1980_oncesi+_1980_2000_arasi+_2000_sonrasi +0.0000001)*100 AS _2000SonrasiOrani
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT ilce_adi, mahalle_adi,CokHasarliBinaOrani,AgirHasarliBinaOrani,
OrtaHasarliBinaOrani,HafifHasarliBinaOrani,HasarliBinaOrani,_1980OncesiOrani,_2000SonrasiOrani
FROM BinaOranlari
--ORDER BY _1980OncesiOrani DESC  
ORDER BY _2000SonrasiOrani DESC	
								-- Eski binalar�n �o�unluk oldu�u yerlerde �ok A��r hasarl� bina oranlar� genelde daha y�ksekken,
								-- yeni binalar�n �o�unluk oldu�u yerlerde Hafif hasarl� bina oranlar� genelde daha y�ksek.
								-- Bina ya��n�n al�nacak hasar�n �iddetine etkisi oldu�u s�ylenebilir,
								-- fakat ayk�r� �rneklerin de mevcut olmas�n�n da etkisiyle, binan�n ya�� haricinde, 
								-- elimizde bulunmayan bir �ok farkl� de�i�ken
								-- al�nacak hasar�n belirlenmesinde etkili denebilir. (binan�n temeli, kullan�lan materyallerin t�r� ve kalitesi vs.)


								-- En eski binalar�na sahip il�e ve mahalleler ilk be�;
								-- FAT�H - YED�KULE
								-- FAT�H - SARIDEM�R
								-- FAT�H - YAVUZ S�NAN 
								-- FAT�H - KOCA MUSTAFAPA�A
								-- BEYO�LU - �UKUR

								-- En yeni binalara sahip il�e ve mahalleler ilk be�;
								-- �EKMEK�Y - N��ANTEPE
								-- S�L�VR� - KAVAKLI
								-- S�L�VR� - H�RR�YET
								-- ��LE - DO�ANCILI
								-- TUZLA - AKFIRAT


------ Binalar�n �ok katl� olmas� al�nan hasar� etkiliyor mu?
-- 9-19 katl� binalar�n oldu�u b�lgelerde hasar �ok mu az m�?
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,HasarliBinaOrani,_9_19_kat_arasi)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina,
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)*1.0
/
(_1980_oncesi+_1980_2000_arasi+_2000_sonrasi)*100 AS HasarliBinaOrani,
_9_19_kat_arasi
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT *
FROM BinaOranlari
WHERE _9_19_kat_arasi > 0		-- �o�u b�lgede 9 - 19 kat aras� bina yok, sadece olan b�lgelere bak�l�yor
--ORDER BY HasarliBinaOrani DESC
ORDER BY _9_19_kat_arasi DESC

									-- Yine ayk�r� g�zlemler bulunmakla beraber,
									-- hasarl� bina oran� y�ksek b�lgelerde, fazla say�da �ok katl� bina olmad��� s�ylenebilir,
									-- bu durum �ok katl� binalar�n daha yeni teknolojik y�ntemlerle/ara�larla yap�l�p
									-- daha dayan�kl� olmalar�na ba�lanabilir.




---- Binalar�n ya�lar� ile deprem durumlar�nda ya�anan tesisat sorunlar�n�n bir ili�kisi var m�?
SELECT d.ilce_adi,
SUM(dogalgaz_boru_hasari) AS �lceTopHasarliDogalgaz,
SUM(icme_suyu_boru_hasari) AS �lceTopHasarli�cmeSuyu,
SUM(atik_su_boru_hasari) AS �lceTopHasarliAtikSuyu,
SUM(_1980_oncesi) AS �lceTop1980,
SUM(_1980_2000_arasi) AS �lceTop1980_2000,
SUM(_2000_sonrasi) AS �lceTop2000,
SUM(dogalgaz_boru_hasari+icme_suyu_boru_hasari+atik_su_boru_hasari) AS �lceTopTesisatHasari
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
ORDER BY �lceTop1980 DESC -- Eski binalar�n oldu�u b�lgelerdeki toplam hasarl� tesisat; 72, 20, 25, 27, 32...
--ORDER BY �lceTop2000 DESC	-- Yeni binalar�n oldu�u b�lgelerdeki toplam hasarl� tesisat; 86, 40, 64, 25, 115...
--ORDER BY �lceTop1980_2000 DESC -- Yeni binalar�n �o�unlukta oldu�u baz� b�lgelerde, 1980-2000 aras� binalar da �o�unlukta
								-- ve bu durum kar���kl�k yarat�yor. 

							-- Yeni binalar�n �o�unlukta oldu�u il�elerde tesisat sorunlar� daha fazla g�r�n�yor 
							-- olsa da sorunun yeni binalardan m� yoksa 1980-2000 aras� binalardan m� kaynakland���
							-- net ay�rt edilemiyor.

SELECT d.ilce_adi,
SUM(dogalgaz_boru_hasari) AS �lceTopHasarliDogalgaz,
SUM(icme_suyu_boru_hasari) AS �lceTopHasarli�cmeSuyu,
SUM(atik_su_boru_hasari) AS �lceTopHasarliAtikSuyu,
SUM(_1980_oncesi) AS �lceTop1980,
SUM(_1980_2000_arasi) AS �lceTop1980_2000,
SUM(_2000_sonrasi) AS �lceTop2000,
SUM(dogalgaz_boru_hasari+icme_suyu_boru_hasari+atik_su_boru_hasari) AS �lceTopTesisatHasari
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
HAVING (SUM(_2000_sonrasi)*1.0/SUM(_1980_2000_arasi + _1980_oncesi)) > 1 -- Eski binalar toplam�n�n yeni bina say�s�na e�it olmad���, 
																		 -- yeni bina say�s�n�n daha fazla oldu�u k�s�m ile s�n�rland�rma
ORDER BY (SUM(_2000_sonrasi)*1.0/SUM(_1980_2000_arasi + _1980_oncesi)) DESC
																		 -- S�ralama bu (yeni binalar/eski binalar toplam�) oran�n�n gittik�e azald��� s�rada,
																		 -- yani a�a�� indik�e eski binalar toplam� yeni binalar toplam�na yakla��yor.
																		 -- (Yeni binalar/eski binalar toplam�) oran� azald�k�a da hasar art�yor.
																		 -- Yine kesin bir yorum yapmak pek m�mk�n olmasa da yeni binalar�n �ok hasarl� tesisata
																		 -- sebep olmas�n�n m�mk�n olmad���, sorunun her b�lgede en az yeni binalar kadar 
																		 -- eski binalar�n da olmas�ndan kaynakland��� s�ylenebilir.
 
