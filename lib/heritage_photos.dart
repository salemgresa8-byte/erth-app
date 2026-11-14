part of 'main.dart';

// Verified Wikimedia Commons photos per catalog entry (generated).
// URLs use the 960px standard thumbnail width (Wikimedia rejects 640/800);
// [smallPhoto] derives the 500px variant for cards and strips.
const kPhotoSet = <String, List<(String, String, String)>>{
  'leptis': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Leptis_libya.jpg/960px-Leptis_libya.jpg',
      'أعمدة شامخة في لبدة الكبرى',
      'Towering columns at Leptis Magna'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Leptis_Magna_%284%29_%288288854983%29.jpg/960px-Leptis_Magna_%284%29_%288288854983%29.jpg',
      'الشارع المعمّد المؤدي إلى الأقواس',
      'Colonnaded street leading to the arches'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Leptis_Magna_%2868%29_%288288884867%29.jpg/960px-Leptis_Magna_%2868%29_%288288884867%29.jpg',
      'أعمدة ورواق في قلب المدينة',
      'Columns and portico in the city centre'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Leptis_Magna_%2861%29_%288288891269%29.jpg/960px-Leptis_Magna_%2861%29_%288288891269%29.jpg',
      'أطلال المدينة على ساحل المتوسط',
      'City ruins on the Mediterranean shore'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Theatre%2C_Leptis_Magna%2C_Libya.jpg/960px-Theatre%2C_Leptis_Magna%2C_Libya.jpg',
      'المسرح الروماني ومدرّجاته',
      'The Roman theatre and its tiers'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Leptis_Magna_%2873%29_%288288880423%29.jpg/960px-Leptis_Magna_%2873%29_%288288880423%29.jpg',
      'نقش لاتيني منحوت في الحجر',
      'Latin inscription carved in stone'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Circus_%28Leptis_Magna%29.jpg/960px-Circus_%28Leptis_Magna%29.jpg',
      'ميدان سباق العربات (السيرك)',
      'The chariot-racing circus'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Byzantine_gate%2C_Leptis_Magna.jpg/960px-Byzantine_gate%2C_Leptis_Magna.jpg',
      'البوابة البيزنطية',
      'The Byzantine gate'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Roman_Amphitheatre%2C_Leptis_Magna_4.jpg/960px-Roman_Amphitheatre%2C_Leptis_Magna_4.jpg',
      'المدرّج الروماني (الأمفيثياتر)',
      'The Roman amphitheatre'
    ),
  ],
  'cyrene': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Temple_of_Zeus_-_Cyrene.jpg/960px-Temple_of_Zeus_-_Cyrene.jpg',
      'معبد زيوس في قورينا',
      'Temple of Zeus at Cyrene'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Temple_of_Zeus_in_Cyrene.jpg/960px-Temple_of_Zeus_in_Cyrene.jpg',
      'معبد زيوس من منظور مرتفع',
      'Temple of Zeus from above'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Temple_of_Zeus_%D9%80_Cyrene.jpg/960px-Temple_of_Zeus_%D9%80_Cyrene.jpg',
      'انعكاس أعمدة المعبد بعد المطر',
      'The temple reflected after rain'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/CireneTempioZeus1999.jpg/960px-CireneTempioZeus1999.jpg',
      'الأعمدة الدورية الضخمة',
      'The massive Doric colonnade'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Cyrene_2.jpg/960px-Cyrene_2.jpg',
      'أعمدة معبد زيوس عن قرب',
      'Close view of the temple columns'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/CireneAgor%C3%A0Altari.jpg/960px-CireneAgor%C3%A0Altari.jpg',
      'مذابح الأغورا',
      'Altars of the Agora'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/29_W_Agora_propylaeum.jpg/960px-29_W_Agora_propylaeum.jpg',
      'المدخل الغربي للأغورا',
      'West gateway of the Agora'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Agora_of_Cyrene.jpg/960px-Agora_of_Cyrene.jpg',
      'الأغورا: قلب الحياة العامة',
      'The Agora, heart of civic life'
    ),
  ],
  'sabratha': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Theatre_of_Sabratha%2C_Libya.jpg/960px-Theatre_of_Sabratha%2C_Libya.jpg',
      'واجهة المسرح ذات الطوابق الثلاثة',
      'The three-storey stage front'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Sabratha_theatre_2.jpg/960px-Sabratha_theatre_2.jpg',
      'أعمدة الواجهة المسرحية عن قرب',
      'Stage-front columns up close'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Ancient_Roman_theatre_%28Sabratha%29.jpg/960px-Ancient_Roman_theatre_%28Sabratha%29.jpg',
      'المسرح يطل من بعيد',
      'The theatre seen from afar'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Sabratha_Theatre_-_013.JPG/960px-Sabratha_Theatre_-_013.JPG',
      'الأقواس الخارجية للمسرح',
      'The theatre\'s outer arcades'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Ancient_Theatre_-_Sabratha_-_Libya_02.jpg/960px-Ancient_Theatre_-_Sabratha_-_Libya_02.jpg',
      'المدرّجات والأوركسترا',
      'Seating tiers and orchestra'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Ancient_Theatre_-_Sabratha_-_Libya_26.jpg/960px-Ancient_Theatre_-_Sabratha_-_Libya_26.jpg',
      'ممر مقبّب تحت المدرجات',
      'Vaulted passage beneath the seats'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Ancient_Theatre_-_Sabratha_-_Libya_20.jpg/960px-Ancient_Theatre_-_Sabratha_-_Libya_20.jpg',
      'مدرّجات المسرح الحجرية',
      'Stone seating of the theatre'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Ancient_Theatre_-_Sabratha_-_Libya_25.jpg/960px-Ancient_Theatre_-_Sabratha_-_Libya_25.jpg',
      'أطلال المدينة قرب البحر',
      'City ruins by the sea'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Isis_Temple_-_Sabratha_03.jpg/960px-Isis_Temple_-_Sabratha_03.jpg',
      'معبد إيزيس المطل على البحر',
      'Temple of Isis overlooking the sea'
    ),
  ],
  'acacus': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Libya_4985_Tadrart_Acacus_Luca_Galuzzi_2007.jpg/960px-Libya_4985_Tadrart_Acacus_Luca_Galuzzi_2007.jpg',
      'كثبان وجبال أكاكوس',
      'Dunes and peaks of the Acacus'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/Tadrart01.JPG/960px-Tadrart01.JPG',
      'مسلّة صخرية طبيعية',
      'A natural rock pinnacle'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Libya_5076_Tadrart_Acacus_Luca_Galuzzi_2007.jpg/960px-Libya_5076_Tadrart_Acacus_Luca_Galuzzi_2007.jpg',
      'ممر صخري بين الجبال',
      'A rocky canyon'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Libya_5101_Fozzigiaren_Arch_Tadrart_Acacus_Luca_Galuzzi_2007.jpg/960px-Libya_5101_Fozzigiaren_Arch_Tadrart_Acacus_Luca_Galuzzi_2007.jpg',
      'قوس أفزجار الصخري',
      'The Fozzigiaren rock arch'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Tadrart_Acacus_1.jpg/960px-Tadrart_Acacus_1.jpg',
      'رسوم صخرية ملوّنة لحيوانات وبشر',
      'Painted rock art of animals and people'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Libya_4924_Pictograms_Tadrart_Acacus_Luca_Galuzzi_2007.jpg/960px-Libya_4924_Pictograms_Tadrart_Acacus_Luca_Galuzzi_2007.jpg',
      'رسوم رعوية من عصور ما قبل التاريخ',
      'Prehistoric pastoral pictograms'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/%D9%85%D8%B9%D9%84%D9%85_%D8%A7%D8%B6%D8%A7%D8%B6_%D9%88%D8%B3%D8%B7_%D8%AC%D8%A8%D8%A7%D9%84_%D8%A7%D9%83%D8%A7%D9%83%D9%88%D8%B3_%D9%84%D9%8A%D8%A8%D9%8A%D8%A7.jpg/960px-%D9%85%D8%B9%D9%84%D9%85_%D8%A7%D8%B6%D8%A7%D8%B6_%D9%88%D8%B3%D8%B7_%D8%AC%D8%A8%D8%A7%D9%84_%D8%A7%D9%83%D8%A7%D9%83%D9%88%D8%B3_%D9%84%D9%8A%D8%A8%D9%8A%D8%A7.jpg',
      'معلم صخري وسط جبال أكاكوس',
      'A rock landmark in the Acacus'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Akakus-Gebirge_-_Bizarre_Felsformationen.jpg/960px-Akakus-Gebirge_-_Bizarre_Felsformationen.jpg',
      'تشكيلات صخرية نحتتها الرياح',
      'Wind-carved rock formations'
    ),
  ],
  'ghadames': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Libya_Ghadames_Old_Town_Rooftop_View.JPG/960px-Libya_Ghadames_Old_Town_Rooftop_View.JPG',
      'أسطح غدامس المتصلة',
      'Connected rooftops of Ghadames'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Ghadames_Panorama_April_2004.jpg/960px-Ghadames_Panorama_April_2004.jpg',
      'مبانٍ بيضاء بأقواس تقليدية',
      'White arcaded traditional buildings'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Ghadames_Old_city_from_the_air.jpg/960px-Ghadames_Old_city_from_the_air.jpg',
      'المدينة القديمة من الجو',
      'The old town from the air'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Old_Ghadames_%285282815851%29.jpg/960px-Old_Ghadames_%285282815851%29.jpg',
      'زقاق أبيض في المدينة القديمة',
      'A whitewashed lane in the old town'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Park_al_touta_in_ghadames_city.jpg/960px-Park_al_touta_in_ghadames_city.jpg',
      'ساحة التوتة',
      'Al-Touta square'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Libya_Ghadames_Old_Town_Spring_Water_Pool.JPG/960px-Libya_Ghadames_Old_Town_Spring_Water_Pool.JPG',
      'عين الفرس: النبع التاريخي',
      'Ain al-Faras, the historic spring'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Ghadames_street_at_moring.jpg/960px-Ghadames_street_at_moring.jpg',
      'الممرات المسقوفة الباردة',
      'Cool covered passageways'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Ghadames_-_Altstadt.jpg/960px-Ghadames_-_Altstadt.jpg',
      'زخارف حمراء داخل بيت غدامسي',
      'Red ornament inside a Ghadamesi house'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Ghadames_4.jpg/960px-Ghadames_4.jpg',
      'نقوش جدارية تقليدية',
      'Traditional wall decoration'
    ),
  ],
  'redcastle': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Red_Castle_Of_Tripoli.jpg/960px-Red_Castle_Of_Tripoli.jpg',
      'السرايا الحمراء على الواجهة البحرية',
      'The Red Castle on the waterfront'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Old_Castle_at_sunset%2C_Tripoli_-_Libya.jpg/960px-Old_Castle_at_sunset%2C_Tripoli_-_Libya.jpg',
      'أسوار القلعة عند الغروب',
      'Castle walls at sunset'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Red_Castle_Museum.jpg/960px-Red_Castle_Museum.jpg',
      'السرايا الحمراء ومتحفها',
      'The Red Castle and its museum'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Red_castle_wall_tripoli_libya.JPG/960px-Red_castle_wall_tripoli_libya.JPG',
      'أسوار القلعة الحجرية',
      'The castle\'s stone walls'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Red_Castle_%28Assaraya_Alhamra%29%2C_Tripoli%2C_Libya.jpg/960px-Red_Castle_%28Assaraya_Alhamra%29%2C_Tripoli%2C_Libya.jpg',
      'برج القلعة بين النخيل',
      'Castle tower among palms'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Tripoli_Castle_%26_Teatro_Miramare.jpg/960px-Tripoli_Castle_%26_Teatro_Miramare.jpg',
      'صورة تاريخية للقلعة',
      'Historic view of the castle'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/%D8%B3%D8%B1%D8%A7%D9%8A_%D8%A7%D9%84%D8%AD%D9%85%D8%B1%D8%A7%D8%A1_%D9%81%D9%8A_%D8%A7%D9%84%D9%84%D9%8A%D9%84.jpg/960px-%D8%B3%D8%B1%D8%A7%D9%8A_%D8%A7%D9%84%D8%AD%D9%85%D8%B1%D8%A7%D8%A1_%D9%81%D9%8A_%D8%A7%D9%84%D9%84%D9%8A%D9%84.jpg',
      'السرايا الحمراء ليلًا',
      'The Red Castle at night'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/1010_Kreuzfahrt_G_515_%285129703138%29.jpg/960px-1010_Kreuzfahrt_G_515_%285129703138%29.jpg',
      'لوحة خطية في المتحف',
      'Calligraphy panel in the museum'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/1010_Kreuzfahrt_G_503_%285129697978%29.jpg/960px-1010_Kreuzfahrt_G_503_%285129697978%29.jpg',
      'فسيفساء رومانية لسفينة في المتحف',
      'Roman ship mosaic in the museum'
    ),
  ],
  'marcus': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Marcus_Aurelius_Arch_Tripoli_Libya.jpg/960px-Marcus_Aurelius_Arch_Tripoli_Libya.jpg',
      'قوس ماركوس أوريليوس في طرابلس',
      'Arch of Marcus Aurelius in Tripoli'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Arch_of_Marcus_Aurelius_-_%D9%82%D9%88%D8%B3_%D9%85%D8%A7%D8%B1%D9%83%D9%88%D8%B3_%D8%A3%D9%88%D8%B1%D9%8A%D9%84%D9%8A%D9%88%D8%B3.jpg/960px-Arch_of_Marcus_Aurelius_-_%D9%82%D9%88%D8%B3_%D9%85%D8%A7%D8%B1%D9%83%D9%88%D8%B3_%D8%A3%D9%88%D8%B1%D9%8A%D9%84%D9%8A%D9%88%D8%B3.jpg',
      'القوس داخل المدينة القديمة',
      'The arch within the old city'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Front_view_of_Marcus_Aurelius_Arch.jpg/960px-Front_view_of_Marcus_Aurelius_Arch.jpg',
      'الواجهة الأمامية للقوس',
      'Front view of the arch'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/The_Arch_of_Marcus_Aurelius_in_Tripoli_by_Lugigi_Mayer_1803.jpg/960px-The_Arch_of_Marcus_Aurelius_in_Tripoli_by_Lugigi_Mayer_1803.jpg',
      'لوحة لويجي ماير للقوس عام 1803',
      'Luigi Mayer\'s painting of the arch, 1803'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Arch_of_Marcus_Aurelius_-_Tripoli.jpg/960px-Arch_of_Marcus_Aurelius_-_Tripoli.jpg',
      'القوس بين النخيل',
      'The arch framed by palms'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Arch_of_Marcus_Aurelius_-_panoramio.jpg/960px-Arch_of_Marcus_Aurelius_-_panoramio.jpg',
      'منظر عبر القوس',
      'View through the arch'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Arch_of_Marcus_Aurelius_-_libya_-_%D9%82%D9%88%D8%B3_%D9%85%D8%A7%D8%B1%D9%83%D9%88%D8%B3_%D8%A3%D9%88%D8%B1%D9%8A%D9%84%D9%8A%D9%88%D8%B3_-_%D9%84%D9%8A%D8%A8%D9%8A%D8%A7.jpg/960px-Arch_of_Marcus_Aurelius_-_libya_-_%D9%82%D9%88%D8%B3_%D9%85%D8%A7%D8%B1%D9%83%D9%88%D8%B3_%D8%A3%D9%88%D8%B1%D9%8A%D9%84%D9%8A%D9%88%D8%B3_-_%D9%84%D9%8A%D8%A8%D9%8A%D8%A7.jpg',
      'الطريق المرصوف نحو القوس',
      'Paved approach to the arch'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Arch_of_Marcus_Aurelius_-_libya_-_%D9%82%D9%88%D8%B3_%D9%85%D8%A7%D8%B1%D9%83%D9%88%D8%B3_%D8%A3%D9%88%D8%B1%D9%8A%D9%84%D9%8A%D9%88%D8%B38_-_%D9%84%D9%8A%D8%A8%D9%8A%D8%A7.jpg/960px-Arch_of_Marcus_Aurelius_-_libya_-_%D9%82%D9%88%D8%B3_%D9%85%D8%A7%D8%B1%D9%83%D9%88%D8%B3_%D8%A3%D9%88%D8%B1%D9%8A%D9%84%D9%8A%D9%88%D8%B38_-_%D9%84%D9%8A%D8%A8%D9%8A%D8%A7.jpg',
      'القبة الحجرية المزخرفة من الداخل',
      'The carved stone vault from below'
    ),
  ],
  'ptolemais': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Ptolemais_%285283376622%29.jpg/960px-Ptolemais_%285283376622%29.jpg',
      'أعمدة طلميثة',
      'Columns of Ptolemais'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Palace_of_columns.jpg/960px-Palace_of_columns.jpg',
      'قصر الأعمدة',
      'Palace of the Columns'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Temple_of_Zeus%2C_Tolmeitha.jpg/960px-Temple_of_Zeus%2C_Tolmeitha.jpg',
      'أعمدة معبد زيوس',
      'Columns of the Temple of Zeus'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Colonnaded_Palace_Ptolemais_%2850107806003%29.jpg/960px-Colonnaded_Palace_Ptolemais_%2850107806003%29.jpg',
      'حوض قصر الأعمدة',
      'Pool of the Palace of the Columns'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Colonnaded_Palace%2C_Ptolemais_%2850107820298%29.jpg/960px-Colonnaded_Palace%2C_Ptolemais_%2850107820298%29.jpg',
      'قصر الأعمدة على خلفية البحر',
      'Palace of the Columns against the sea'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Colonnaded_Palace%2C_Ptolemais_%2850107825743%29.jpg/960px-Colonnaded_Palace%2C_Ptolemais_%2850107825743%29.jpg',
      'بقايا القصر المعمّد',
      'Remains of the colonnaded palace'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Ptolemais_odeon.jpg/960px-Ptolemais_odeon.jpg',
      'الأوديون (المسرح الصغير)',
      'The Odeon'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Roman_villa-Ptolemais.jpg/960px-Roman_villa-Ptolemais.jpg',
      'فيلا رومانية',
      'A Roman villa'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Ptolemais_fortified_church_entrance.jpg/960px-Ptolemais_fortified_church_entrance.jpg',
      'مدخل الكنيسة المحصّنة',
      'Entrance of the fortified church'
    ),
  ],
  'apollonia': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Apollonia_ruins_3.jpg/960px-Apollonia_ruins_3.jpg',
      'أعمدة الكنيسة المطلة على البحر',
      'Church columns above the sea'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Apollonia_bysantinsk_basilika.jpg/960px-Apollonia_bysantinsk_basilika.jpg',
      'البازيليكا البيزنطية',
      'The Byzantine basilica'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/East_Church%2C_Apollonia_%2850108622657%29.jpg/960px-East_Church%2C_Apollonia_%2850108622657%29.jpg',
      'الكنيسة الشرقية',
      'The East Church'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Apollonia%2C_West_Church_%2850108392286%29.jpg/960px-Apollonia%2C_West_Church_%2850108392286%29.jpg',
      'الكنيسة الغربية',
      'The West Church'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Apollonia_Libya.jpg/960px-Apollonia_Libya.jpg',
      'ساحل أبولونيا',
      'The Apollonia coast'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Apollonia_portoriental.jpg/960px-Apollonia_portoriental.jpg',
      'الميناء الشرقي',
      'The eastern harbour'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Apollonia_remparts.jpg/960px-Apollonia_remparts.jpg',
      'أسوار المدينة',
      'City ramparts'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/%D8%B9%D8%A8%D9%82_%D8%A7%D9%84%D8%AA%D8%A7%D8%B1%D9%8A%D8%AE_%D8%A7%D9%84%D9%84%D9%8A%D8%A8%D9%8A002.jpg/960px-%D8%B9%D8%A8%D9%82_%D8%A7%D9%84%D8%AA%D8%A7%D8%B1%D9%8A%D8%AE_%D8%A7%D9%84%D9%84%D9%8A%D8%A8%D9%8A002.jpg',
      'أعمدة عند الغروب',
      'Columns at sunset'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/%D9%85%D8%B3%D8%B1%D8%AD_%D8%A7%D8%BA%D8%B1%D9%8A%D9%82%D9%8A_%D9%85%D8%B7%D9%84_%D8%B9%D9%84%D9%89_%D8%A7%D9%84%D8%A8%D8%AD%D8%B1.jpg/960px-%D9%85%D8%B3%D8%B1%D8%AD_%D8%A7%D8%BA%D8%B1%D9%8A%D9%82%D9%8A_%D9%85%D8%B7%D9%84_%D8%B9%D9%84%D9%89_%D8%A7%D9%84%D8%A8%D8%AD%D8%B1.jpg',
      'المسرح الإغريقي المطل على البحر',
      'Greek theatre facing the sea'
    ),
  ],
  'qasralhaj': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Gasr_Al-Hajj.jpg/960px-Gasr_Al-Hajj.jpg',
      'قصر الحاج من الخارج',
      'Qasr al-Hajj from outside'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Gasr_Al-Hajj_-_inside.jpg/960px-Gasr_Al-Hajj_-_inside.jpg',
      'الفناء الدائري وغرف التخزين',
      'Circular courtyard and storage cells'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Nalut_old_20.jpg/960px-Nalut_old_20.jpg',
      'غرف تخزين في قصر نالوت',
      'Storage cells at Nalut'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Nalut1.jpg/960px-Nalut1.jpg',
      'مخازن قصر نالوت',
      'Granary cells of Nalut'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Nalut_ruins.jpg/960px-Nalut_ruins.jpg',
      'قصر نالوت في جبل نفوسة',
      'Nalut ksar, Nafusa Mountains'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Nalut_old_2.jpg/960px-Nalut_old_2.jpg',
      'بقايا نالوت القديمة',
      'Old Nalut remains'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/1/1f/Nalut_Ksar.jpg',
      'قصر نالوت: مخزن جبلي شقيق',
      'Nalut ksar, a sister mountain granary'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/%D9%82%D8%B5%D8%B1_%D9%83%D8%A7%D8%A8%D8%A7%D9%88_2024.jpg/960px-%D9%82%D8%B5%D8%B1_%D9%83%D8%A7%D8%A8%D8%A7%D9%88_2024.jpg',
      'قصر كاباو: مخزن جبلي مماثل',
      'Qasr Kabaw, a sister mountain granary'
    ),
  ],
  'garama': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Garma_%28Garama%29_-_Ruinen_der_antiken_Stadt_Garama.jpg/960px-Garma_%28Garama%29_-_Ruinen_der_antiken_Stadt_Garama.jpg',
      'أطلال مدينة جرمة القديمة',
      'Ruins of old Germa'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/Germa_-_Garamantengr%C3%A4ber.jpg/960px-Germa_-_Garamantengr%C3%A4ber.jpg',
      'أهرامات وقبور الجرمنتيين',
      'Garamantian pyramid tombs'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Garma_%28Garama%29_-_Ruinen_der_antiken_Stadt_Garma_02.jpg/960px-Garma_%28Garama%29_-_Ruinen_der_antiken_Stadt_Garma_02.jpg',
      'جدران من الطوب اللبن',
      'Mudbrick walls'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Garma_%28Garama%29_-_Ruinen_der_antiken_Stadt_Garma_03.jpg/960px-Garma_%28Garama%29_-_Ruinen_der_antiken_Stadt_Garma_03.jpg',
      'بقايا البيوت الطينية',
      'Remains of mud houses'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Garma_%28Garama%29_-_Ruinen_der_antiken_Stadt_Garama_05.jpg/960px-Garma_%28Garama%29_-_Ruinen_der_antiken_Stadt_Garama_05.jpg',
      'أزقة المدينة المتهدمة',
      'Crumbling lanes of the old town'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Echoes_of_Garama%2C_Timeless_Heritage_in_the_Libyan_Sahara.jpg/960px-Echoes_of_Garama%2C_Timeless_Heritage_in_the_Libyan_Sahara.jpg',
      'جرمة في قلب الصحراء الليبية',
      'Germa in the Libyan Sahara'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Germa_-_Talsohle_des_Wadi_Mathandous.jpg/960px-Germa_-_Talsohle_des_Wadi_Mathandous.jpg',
      'وادي متخندوش القريب',
      'The nearby Wadi Mathendous'
    ),
  ],
  'silin': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Villa_of_the_Nile_Mosaic_fishermen.jpg/960px-Villa_of_the_Nile_Mosaic_fishermen.jpg',
      'فسيفساء الصيادين من فيلا النيل - لبدة',
      'Fishermen mosaic, Villa of the Nile, Leptis'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/1/12/Musicians_from_the_Zliten_mosaic_2.JPG',
      'موسيقيون في فسيفساء زليتن المجاورة',
      'Musicians, neighbouring Zliten villa mosaic'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/8/8d/Bestiarii.jpg',
      'إفريز صيد من فسيفساء زليتن',
      'Hunting frieze from the Zliten mosaic'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Leptis_Magna_%2861%29_%288288891269%29.jpg/960px-Leptis_Magna_%2861%29_%288288891269%29.jpg',
      'ساحل لبدة القريب من سيلين',
      'The Leptis coast near Silin'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/25_Eastern_Baths.jpg/960px-25_Eastern_Baths.jpg',
      'حمّامات رومانية في لبدة',
      'Roman baths at Leptis'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/1010_Kreuzfahrt_G_503_%285129697978%29.jpg/960px-1010_Kreuzfahrt_G_503_%285129697978%29.jpg',
      'فسيفساء سفينة رومانية',
      'Roman ship mosaic'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Red_Castle_Museum.jpg/960px-Red_Castle_Museum.jpg',
      'متحف السرايا الحمراء - طرابلس',
      'Red Castle Museum, Tripoli'
    ),
  ],
  'gaberoun': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Lake_Gaberoun_%285282881127%29.jpg/960px-Lake_Gaberoun_%285282881127%29.jpg',
      'بحيرة قبرعون',
      'Lake Gaberoun'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Gaberoun.jpg/960px-Gaberoun.jpg',
      'البحيرة بين الكثبان',
      'The lake among the dunes'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Alfejej_-_Oase_Gabrun%2C_See%2C_von_Palmen_ums%C3%A4umt.jpg/960px-Alfejej_-_Oase_Gabrun%2C_See%2C_von_Palmen_ums%C3%A4umt.jpg',
      'بحيرة يحفّها النخيل',
      'Palm-fringed lake'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Alfejej_-_Oase_Gabrun%2C_Dattelpalme_mit_See.jpg/960px-Alfejej_-_Oase_Gabrun%2C_Dattelpalme_mit_See.jpg',
      'نخلة على ضفة البحيرة',
      'A palm on the shore'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Alfejej_-_Oase_Gabrun%2C_Dattelpalmen.jpg/960px-Alfejej_-_Oase_Gabrun%2C_Dattelpalmen.jpg',
      'بساتين النخيل',
      'Palm groves'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Libya_5391_Ubari_Lakes_Luca_Galuzzi_2007.jpg/960px-Libya_5391_Ubari_Lakes_Luca_Galuzzi_2007.jpg',
      'بحيرات أوباري',
      'The Ubari lakes'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/The_Mandara_Lakes.jpg/960px-The_Mandara_Lakes.jpg',
      'بحيرة مندرة',
      'Mandara lake'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Um_el_Maa_Libya_2002_a.jpg/960px-Um_el_Maa_Libya_2002_a.jpg',
      'بحيرة أم الماء',
      'Umm al-Maa lake'
    ),
  ],
  'waw': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Wau-en-Namus-1.jpg/960px-Wau-en-Namus-1.jpg',
      'المخروط البركاني والبحيرات',
      'Volcanic cone and lakes'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Wau-en-Namus-2.jpg/960px-Wau-en-Namus-2.jpg',
      'بحيرة زرقاء ونخيل في الفوهة',
      'Blue lake and palms in the crater'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Waw_an-Namus-gr%C3%BCner_See.jpg/960px-Waw_an-Namus-gr%C3%BCner_See.jpg',
      'البحيرة الخضراء',
      'The green lake'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Waw_an-Namus-roter_See.jpg/960px-Waw_an-Namus-roter_See.jpg',
      'البحيرة الحمراء',
      'The red lake'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Waw_an-Namus-Zentrum.jpg/960px-Waw_an-Namus-Zentrum.jpg',
      'مركز الفوهة',
      'The centre of the caldera'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/Waw_an-Namus-zentraler_Krater.jpg/960px-Waw_an-Namus-zentraler_Krater.jpg',
      'الفوهة المركزية',
      'The central crater'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Wau-en-Namus_%28crop%29.jpg/960px-Wau-en-Namus_%28crop%29.jpg',
      'المخروط البركاني',
      'The volcanic cone'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/ISS-65_Waw_an_Namus%2C_Libya.jpg/960px-ISS-65_Waw_an_Namus%2C_Libya.jpg',
      'الفوهة من محطة الفضاء الدولية',
      'The caldera seen from the ISS'
    ),
  ],
  'medusa': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Gorgone_libia_by_marcotambara.jpg',
      'رأس ميدوسا عن قرب',
      'The Medusa head up close'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Leptis_Magna_-_Fragment_Kopf.jpg/960px-Leptis_Magna_-_Fragment_Kopf.jpg',
      'رأس ميدوسا في الحجر',
      'Medusa head in stone'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Forum_Leptis_Magna_04.JPG/960px-Forum_Leptis_Magna_04.JPG',
      'رؤوس ميدوسا بين أطلال المنتدى',
      'Medusa heads among the forum ruins'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Libya_5420_Leptis_Magna_Luca_Galuzzi_2007.jpg/960px-Libya_5420_Leptis_Magna_Luca_Galuzzi_2007.jpg',
      'ميدالية حجرية في المنتدى السيفيري',
      'Stone medallion in the Severan Forum'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/7_Severan_Forum.jpg/960px-7_Severan_Forum.jpg',
      'جدران المنتدى السيفيري',
      'Walls of the Severan Forum'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/6_Severan_Forum.jpg/960px-6_Severan_Forum.jpg',
      'بوابة في المنتدى السيفيري',
      'A doorway in the Severan Forum'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/8_Severan_Forum.jpg/960px-8_Severan_Forum.jpg',
      'ممرات المنتدى',
      'Forum passageways'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Fig06_Pg11Forum_%2850046550976%29.jpg/960px-Fig06_Pg11Forum_%2850046550976%29.jpg',
      'رسم للأقواس ورؤوس ميدوسا',
      'Drawing of the arcades with Medusa roundels'
    ),
  ],
  'severus': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Bust_of_Septimius_Severus_%28GL_357%29.jpg/960px-Bust_of_Septimius_Severus_%28GL_357%29.jpg',
      'تمثال نصفي لسبتيموس سيفيروس',
      'Bust of Septimius Severus'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Septimius_Severus_busto-Musei_Capitolini.jpg/960px-Septimius_Severus_busto-Musei_Capitolini.jpg',
      'تمثال نصفي في متاحف الكابيتول',
      'Bust in the Capitoline Museums'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Leptis_Magna_Arch_of_Septimius_Severus.jpg/960px-Leptis_Magna_Arch_of_Septimius_Severus.jpg',
      'قوس سيبتيموس سيفيروس في لبدة',
      'Arch of Septimius Severus, Leptis'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/The_Arch_of_Septimius_Severus_%28Leptis_Magna%29.jpg/960px-The_Arch_of_Septimius_Severus_%28Leptis_Magna%29.jpg',
      'القوس الرباعي الواجهات',
      'The four-way arch'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/The_upper_part_the_Arch_of_Septimius_Severus_%28Leptis_Magna%29.jpg/960px-The_upper_part_the_Arch_of_Septimius_Severus_%28Leptis_Magna%29.jpg',
      'الجزء العلوي المزخرف من القوس',
      'Ornate upper section of the arch'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Leptis_Magna_-_Triumphbogen_des_Septimius_Severus_203_n._Chr..jpg/960px-Leptis_Magna_-_Triumphbogen_des_Septimius_Severus_203_n._Chr..jpg',
      'القوس على الطريق الرئيسي',
      'The arch on the main road'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/The_upper_part_the_Arch_of_Septimius_Severus_in_Leptis_Magna.jpg/960px-The_upper_part_the_Arch_of_Septimius_Severus_in_Leptis_Magna.jpg',
      'أفاريز القوس المنحوتة',
      'The arch\'s carved friezes'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Severan_Basilica.JPG/960px-Severan_Basilica.JPG',
      'البازيليكا السيفيرية',
      'The Severan Basilica'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Severan_Basilica_Lepcis_Magna_%2850115876476%29.jpg/960px-Severan_Basilica_Lepcis_Magna_%2850115876476%29.jpg',
      'أعمدة البازيليكا السيفيرية',
      'Columns of the Severan Basilica'
    ),
  ],
  'zliten': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/1/12/Musicians_from_the_Zliten_mosaic_2.JPG',
      'موسيقيون مع الأرغن المائي',
      'Musicians with a water organ'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Musicians_from_Zliten_mosaic.JPG/960px-Musicians_from_Zliten_mosaic.JPG',
      'فرقة موسيقية في الفسيفساء',
      'A band of musicians'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/7/7e/Gladiators_from_the_Zliten_mosaic_3.JPG',
      'مصارعون بدروعهم',
      'Gladiators with their shields'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Gladiators_from_the_Zliten_mosaic_4.JPG/960px-Gladiators_from_the_Zliten_mosaic_4.JPG',
      'مشهد في الحلبة',
      'An arena scene'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/8/8d/Bestiarii.jpg',
      'إفريز الصيد والحيوانات',
      'Hunting frieze with animals'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/5/53/Besti%C3%A1rios.jpg',
      'تفاصيل إفريز الحيوانات',
      'Detail of the animal frieze'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/1010_Kreuzfahrt_G_503_%285129697978%29.jpg/960px-1010_Kreuzfahrt_G_503_%285129697978%29.jpg',
      'فسيفساء سفينة من متحف طرابلس',
      'Ship mosaic, Tripoli museum'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Red_Castle_Museum.jpg/960px-Red_Castle_Museum.jpg',
      'متحف السرايا الحمراء حيث تُعرض',
      'Red Castle Museum, where it is displayed'
    ),
  ],
  'ghadames_ms': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Folio_in_Maghribi_Script_MET_LC-TR_190_19_1_2019-20190711-01.jpg/960px-Folio_in_Maghribi_Script_MET_LC-TR_190_19_1_2019-20190711-01.jpg',
      'ورقة بالخط المغربي',
      'Folio in Maghribi script'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Maghribi_script.jpg/960px-Maghribi_script.jpg',
      'نموذج من الخط المغربي',
      'Maghribi script sample'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Manuscrit_complet_du_Coran%2C_%C3%A9criture_maghr%C3%A9bine%2C_Tlemcen.jpg/960px-Manuscrit_complet_du_Coran%2C_%C3%A9criture_maghr%C3%A9bine%2C_Tlemcen.jpg',
      'مصحف كامل بالخط المغربي - تلمسان',
      'Complete Qur\'an in Maghribi script, Tlemcen'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Coran_in_Kasbah_Museum_of_Tangier_2023.jpg/960px-Coran_in_Kasbah_Museum_of_Tangier_2023.jpg',
      'مصحف في متحف القصبة بطنجة',
      'Qur\'an, Kasbah Museum, Tangier'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Folio_from_a_Qur%E2%80%99an%2C_sura_5%2C12-13_%28F1929.69%29.jpg/960px-Folio_from_a_Qur%E2%80%99an%2C_sura_5%2C12-13_%28F1929.69%29.jpg',
      'ورقة مذهّبة من مصحف مغربي',
      'Gilded Maghribi Qur\'an folio'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/On_the_Calculation_of_Numbers_in_the_Science_of_Astronomy_WDL466.jpg/960px-On_the_Calculation_of_Numbers_in_the_Science_of_Astronomy_WDL466.jpg',
      'مخطوط صحراوي في علم الفلك',
      'Saharan manuscript on astronomy'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Askiyah%27s_Questions_and_al-Maghili%27s_Answers_%28al-Maghili%27s_Tract_on_Politics%29_WDL36.jpg/960px-Askiyah%27s_Questions_and_al-Maghili%27s_Answers_%28al-Maghili%27s_Tract_on_Politics%29_WDL36.jpg',
      'مخطوط أجوبة المغيلي',
      'Al-Maghili\'s Answers manuscript'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Ghadames_-_Altstadt.jpg/960px-Ghadames_-_Altstadt.jpg',
      'بيت غدامسي حُفظت فيه المخطوطات',
      'A Ghadamesi house where manuscripts were kept'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/House_at_Ghadames_%285282834541%29.jpg/960px-House_at_Ghadames_%285282834541%29.jpg',
      'مجلس تقليدي في غدامس',
      'Traditional sitting room in Ghadames'
    ),
  ],
  'apollo_cyrene': [
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Ancient_Stone_Gateway_and_Propylaeum_-_Sanctuary_of_Apollo_Cyrene_Shahat_Libya.jpg/960px-Ancient_Stone_Gateway_and_Propylaeum_-_Sanctuary_of_Apollo_Cyrene_Shahat_Libya.jpg',
      'بوابة حرم أبولون',
      'Gateway of the Sanctuary of Apollo'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Sanctuary_of_Apollo_from_Fountain_View_-_Cyrene_Shahat_Libya.jpg/960px-Sanctuary_of_Apollo_from_Fountain_View_-_Cyrene_Shahat_Libya.jpg',
      'الحرم من جهة النبع',
      'The sanctuary from the spring'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/CireneSantuarioApollo01.jpg/960px-CireneSantuarioApollo01.jpg',
      'مشهد عام للحرم',
      'Overview of the sanctuary'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/CireneTempioApollo.jpg/960px-CireneTempioApollo.jpg',
      'أعمدة معبد أبولون',
      'Columns of the Temple of Apollo'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Roman_Propylea%2C_Shahhat%2C_Libya.jpg/960px-Roman_Propylea%2C_Shahhat%2C_Libya.jpg',
      'البوابة الرومانية',
      'The Roman propylaea'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Temple_of_Apollo%2C_Cyrene_%2850144963856%29.jpg/960px-Temple_of_Apollo%2C_Cyrene_%2850144963856%29.jpg',
      'معبد أبولون وأعمدته',
      'Temple of Apollo and its columns'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Temple_of_Apollo%2C_Cyrene.jpg/960px-Temple_of_Apollo%2C_Cyrene.jpg',
      'الحرم من الجو',
      'The sanctuary from the air'
    ),
    (
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/350A6967%D9%85%D8%AF%D9%8A%D9%86%D8%A9_%D8%B4%D8%AD%D8%A7%D8%AA_%D9%84%D9%8A%D8%A8%D9%8A%D8%A7.jpg/960px-350A6967%D9%85%D8%AF%D9%8A%D9%86%D8%A9_%D8%B4%D8%AD%D8%A7%D8%AA_%D9%84%D9%8A%D8%A8%D9%8A%D8%A7.jpg',
      'مدينة شحات الأثرية',
      'The ancient city of Shahat'
    ),
  ],
};
