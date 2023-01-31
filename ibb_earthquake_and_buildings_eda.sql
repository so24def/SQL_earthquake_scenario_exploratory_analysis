--Genel bakýþ
SELECT * 
FROM ibb.dbo.deprem
SELECT * 
FROM ibb.dbo.bina



--Join iþlemi
-- iki tabloda da id kolonunu primary key seçerek import etmiþtim
-- mahalle_koy_uavt ve mahalle_uavt kolonlarý ise ilçelerin ulusal adreslerini içeriyor ve
-- iki tabloda da ortak
SELECT * 
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt



--Tek deðiþkenli inceleme
SELECT *
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
--ORDER BY cok_agir_hasarli_bina_sayisi DESC
--ORDER BY agir_hasarli_bina_sayisi DESC
--ORDER BY orta_hasarli_bina_sayisi DESC
--ORDER BY hafif_hasarli_bina_sayisi DESC
ORDER BY can_kaybi_sayisi DESC



-- Hiç can kaybý olmayan bölgeler? Ýlçe-mahalle bazýnda
SELECT d.ilce_adi,d.mahalle_adi,d.can_kaybi_sayisi
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b
ON d.mahalle_koy_uavt = b.mahalle_uavt
WHERE can_kaybi_sayisi = 0

-- Hiç bir mahallesinde bile can kaybý olmayan, tamamýnda can kaybý yaþanmayan ilçeler?

SELECT d.ilce_adi,SUM(d.can_kaybi_sayisi) AS ÝlceTopCanKaybi
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
HAVING SUM(d.can_kaybi_sayisi) = 0		---- ARNAVUTKÖY VE ÞÝLE ilçelerinin HÝÇ BÝR mahallesinde can kaybý
										--  yaþanmamýþ, bu kriter bakýmýndan en güvenli ilçeler olduðu söylenebilir.






--Tek deðiþkenli inceleme, ilçe bazýnda gruplu
SELECT d.ilce_adi, 
SUM(cok_agir_hasarli_bina_sayisi) AS ÝlceTopCokAgirHasar,
SUM(agir_hasarli_bina_sayisi) AS ÝlceTopAgirHasar,
SUM(orta_hasarli_bina_sayisi) AS ÝlceTopOrtaHasar,
SUM(hafif_hasarli_bina_sayisi) AS ÝlceTopHafifHasar,
SUM(can_kaybi_sayisi) AS ÝlceTopCanKaybi,
SUM(gecici_barinma) AS ÝlceTopSiginak
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
--ORDER BY ÝlceTopCokAgirHasar DESC -- FATÝH, KÜÇÜKÇEKMECE, BAÐCILAR, BAHÇELÝEVLER, BAKIRKÖY...
--ORDER BY ÝlceTopAgirHasar DESC -- FATÝH, KÜÇÜKÇEKMECE, BAÐCILAR, ESENYURT, SÝLÝVRÝ...
--ORDER BY ÝlceTopOrtaHasar DESC -- FATÝH, KÜÇÜKÇEKMECE, BAÐCILAR, ESENYURT, SÝLÝVRÝ...
--ORDER BY ÝlceTopHafifHasar DESC -- FATÝH, BAÐCILAR, ESENYURT, KÜÇÜKÇEKMECE, PENDÝK...
--ORDER BY ÝlceTopCanKaybi DESC -- BAHÇELÝEVLER, KÜÇÜKÇEKMECE, FATÝH, BAÐCILAR, BAKIRKÖY...
ORDER BY ÝlceTopSiginak DESC -- KÜÇÜKÇEKMECE, ESENYURT, BAHÇELÝEVLER, BAÐCILAR, FATÝH...
								
								-- Olasý deprem senaryosunda en çok can kaybý yaþayacak ve hasar alacak bölgelerin
								-- FATÝH, KÜÇÜKÇEKMECE, BAÐCILAR, BAHÇELÝEVLER olacaðý söylenebilir.


--------------------	Ýki deðiþkenli inceleme

------Ýlçe ve mahalle bazýnda; toplamda ne kadar bina hasar görmüþ?
SELECT d.ilce_adi,d.mahalle_adi, 
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)
as ToplamHasarliBina
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
ORDER BY ToplamHasarliBina DESC --Olasý deprem senaryosunda en çok hasar alacak binaya sahip ilçe ve mahalleler ilk beþ:
								-- AVCILAR - YEÞÝLKENT
								-- KÜÇÜKÇEKMECE - ÝNÖNÜ
								-- BAHÇELÝEVLER - ZAFER
								-- SÝLÝVRÝ - SEMÝZKUMLAR
								-- TUZLA - AYDINLI




--
--Toplam bina sayýlarý ve toplam hasarlý bina sayýlarýný karþýlaþtýrmadan önce CTE oluþturacaðým
--Ýlçe ve mahalle bazýnda;
--1) Toplam binalarýn yüzde kaçý hasarlý? 
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
ORDER BY HasarliBinaOrani DESC  --Olasý deprem senaryosunda en çok (hasarlý bina/toplam bina) oranýna sahip olacak
								--ilçe ve mahalleler ilk beþ:
								-- BAKIRKÖY - YEÞÝLYURT				%83 oranda hasarlý bina
								-- BAKIRKÖY - SAKIZAÐACI			%82 oranda hasarlý bina
								-- FATÝH - YEDÝKULE					%82 oranda hasarlý bina
								-- BAKIRKÖY - YENÝMAHALLE			%81 oranda hasarlý bina
								-- BAKIRKÖY - ATAKÖY 3-4-11. KISIM	%81 oranda hasarlý bina




--2) Ayný oranlarý ilçe bazýnda gruplama
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
SELECT ilce_adi,SUM(ToplamHasarliBina) AS ÝlceToplamHasarliBina,SUM(ToplamBina) AS ÝlceToplamBina,
(SUM(ToplamHasarliBina)*1.0/SUM(ToplamBina))*100 AS ÝlceHasarOrani
FROM BinaOranlari
GROUP BY ilce_adi
ORDER BY ÝlceHasarOrani DESC --En çok hasar alan ilçeler
							 --olasý bir deprem senaryosunda en çok hasar alacak ilk 5 ilçe:
							 --BAKIRKÖY %78 oranla hasarlý
							 --ADALAR %76 oranla hasarlý
							 --BAHÇELÝEVLER %75 oranla hasarlý
							 --ZEYTÝNBURNU %72 oranla hasarlý
							 --GÜNGÖREN %72 oranla hasarlý




------ Binalarýn yaþlarý binalarýn alacaðý hasarý ne kadar etkiliyor?

--1) 1980den eski binalarýn çoðunluk olduðu ilçe ve mahallelerde hasar oranlarý nasýl?
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
							   -- Eski binalarýn çoðunlukta olmasý alýnacak hasarý kesin bir þekilde artýrýr
							   -- demek doðru olmayabilir. Örneðin BEYOÐLU - ÇUKUR bölgesindeki binalarýn
							   -- %84ü 1980 öncesinden kalma olmasýna raðmen %35 hasar oranýna sahip,
							   -- tam tersi olarak 1980 öncesinden kalma yapýlandýrma bulundurmamasýna raðmen
							   -- %70lerde bile hasar oraný olan bölgeler bulunmakta.


--2) 2000 ve sonrasýnda yapýlan binalarýn çoðunlukta olduðu bölgelerde durum nasýl?

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
ORDER BY _2000SonrasiOrani DESC		-- Daha yeni binalarýn çoðunlukta olduðu bölgelerde net bir þekilde hasarýn 
									-- az olduðunu söylemek doðru deðil, benzer þekilde farklý örnekler bulunmakta.





-- Tam olarak karþýlaþtýrma yapabilmek için hasarýn türü de önemli, ayný eski-yeni oranlarýný binalardaki hasarýn þiddeti ile karþýlaþtýrmak gerekli
-- Eski binalar için
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
								-- Eski binalarýn çoðunluk olduðu yerlerde Çok Aðýr hasarlý bina oranlarý genelde daha yüksekken,
								-- yeni binalarýn çoðunluk olduðu yerlerde Hafif hasarlý bina oranlarý genelde daha yüksek.
								-- Bina yaþýnýn alýnacak hasarýn þiddetine etkisi olduðu söylenebilir,
								-- fakat aykýrý örneklerin de mevcut olmasýnýn da etkisiyle, binanýn yaþý haricinde, 
								-- elimizde bulunmayan bir çok farklý deðiþken
								-- alýnacak hasarýn belirlenmesinde etkili denebilir. (binanýn temeli, kullanýlan materyallerin türü ve kalitesi vs.)


								-- En eski binalarýna sahip ilçe ve mahalleler ilk beþ;
								-- FATÝH - YEDÝKULE
								-- FATÝH - SARIDEMÝR
								-- FATÝH - YAVUZ SÝNAN 
								-- FATÝH - KOCA MUSTAFAPAÞA
								-- BEYOÐLU - ÇUKUR

								-- En yeni binalara sahip ilçe ve mahalleler ilk beþ;
								-- ÇEKMEKÖY - NÝÞANTEPE
								-- SÝLÝVRÝ - KAVAKLI
								-- SÝLÝVRÝ - HÜRRÝYET
								-- ÞÝLE - DOÐANCILI
								-- TUZLA - AKFIRAT


------ Binalarýn çok katlý olmasý alýnan hasarý etkiliyor mu?
-- 9-19 katlý binalarýn olduðu bölgelerde hasar çok mu az mý?
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
WHERE _9_19_kat_arasi > 0		-- çoðu bölgede 9 - 19 kat arasý bina yok, sadece olan bölgelere bakýlýyor
--ORDER BY HasarliBinaOrani DESC
ORDER BY _9_19_kat_arasi DESC

									-- Yine aykýrý gözlemler bulunmakla beraber,
									-- hasarlý bina oraný yüksek bölgelerde, fazla sayýda çok katlý bina olmadýðý söylenebilir,
									-- bu durum çok katlý binalarýn daha yeni teknolojik yöntemlerle/araçlarla yapýlýp
									-- daha dayanýklý olmalarýna baðlanabilir.




---- Binalarýn yaþlarý ile deprem durumlarýnda yaþanan tesisat sorunlarýnýn bir iliþkisi var mý?
SELECT d.ilce_adi,
SUM(dogalgaz_boru_hasari) AS ÝlceTopHasarliDogalgaz,
SUM(icme_suyu_boru_hasari) AS ÝlceTopHasarliÝcmeSuyu,
SUM(atik_su_boru_hasari) AS ÝlceTopHasarliAtikSuyu,
SUM(_1980_oncesi) AS ÝlceTop1980,
SUM(_1980_2000_arasi) AS ÝlceTop1980_2000,
SUM(_2000_sonrasi) AS ÝlceTop2000,
SUM(dogalgaz_boru_hasari+icme_suyu_boru_hasari+atik_su_boru_hasari) AS ÝlceTopTesisatHasari
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
ORDER BY ÝlceTop1980 DESC -- Eski binalarýn olduðu bölgelerdeki toplam hasarlý tesisat; 72, 20, 25, 27, 32...
--ORDER BY ÝlceTop2000 DESC	-- Yeni binalarýn olduðu bölgelerdeki toplam hasarlý tesisat; 86, 40, 64, 25, 115...
--ORDER BY ÝlceTop1980_2000 DESC -- Yeni binalarýn çoðunlukta olduðu bazý bölgelerde, 1980-2000 arasý binalar da çoðunlukta
								-- ve bu durum karýþýklýk yaratýyor. 

							-- Yeni binalarýn çoðunlukta olduðu ilçelerde tesisat sorunlarý daha fazla görünüyor 
							-- olsa da sorunun yeni binalardan mý yoksa 1980-2000 arasý binalardan mý kaynaklandýðý
							-- net ayýrt edilemiyor.

SELECT d.ilce_adi,
SUM(dogalgaz_boru_hasari) AS ÝlceTopHasarliDogalgaz,
SUM(icme_suyu_boru_hasari) AS ÝlceTopHasarliÝcmeSuyu,
SUM(atik_su_boru_hasari) AS ÝlceTopHasarliAtikSuyu,
SUM(_1980_oncesi) AS ÝlceTop1980,
SUM(_1980_2000_arasi) AS ÝlceTop1980_2000,
SUM(_2000_sonrasi) AS ÝlceTop2000,
SUM(dogalgaz_boru_hasari+icme_suyu_boru_hasari+atik_su_boru_hasari) AS ÝlceTopTesisatHasari
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
HAVING (SUM(_2000_sonrasi)*1.0/SUM(_1980_2000_arasi + _1980_oncesi)) > 1 -- Eski binalar toplamýnýn yeni bina sayýsýna eþit olmadýðý, 
																		 -- yeni bina sayýsýnýn daha fazla olduðu kýsým ile sýnýrlandýrma
ORDER BY (SUM(_2000_sonrasi)*1.0/SUM(_1980_2000_arasi + _1980_oncesi)) DESC
																		 -- Sýralama bu (yeni binalar/eski binalar toplamý) oranýnýn gittikçe azaldýðý sýrada,
																		 -- yani aþaðý indikçe eski binalar toplamý yeni binalar toplamýna yaklaþýyor.
																		 -- (Yeni binalar/eski binalar toplamý) oraný azaldýkça da hasar artýyor.
																		 -- Yine kesin bir yorum yapmak pek mümkün olmasa da yeni binalarýn çok hasarlý tesisata
																		 -- sebep olmasýnýn mümkün olmadýðý, sorunun her bölgede en az yeni binalar kadar 
																		 -- eski binalarýn da olmasýndan kaynaklandýðý söylenebilir.
 
