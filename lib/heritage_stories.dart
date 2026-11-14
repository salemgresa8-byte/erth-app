part of 'main.dart';

// Encyclopedia sections for every built-in catalog entry, shown below the
// short summary on the site page. Order: origins, architecture, significance.

const kStoryHeadings = <(String, String)>[
  ('النشأة والتاريخ', 'Historical Origins & Chronology'),
  ('العمارة والتصميم الهندسي', 'Architecture & Engineering'),
  ('الأهمية الحضارية والعالمية', 'Cultural & Global Significance'),
];

const kRichStory = <String, List<(String, String)>>{
  'leptis': [
    (
      'أسس الفينيقيون لبدة نحو القرن السابع قبل الميلاد مرفأً تجاريًا عند مصب وادي لبدة، ثم دخلت في فلك قرطاج حتى سقوطها عام 146 ق.م فانضمت إلى عالم روما. نالت صفة «بلدية» في عهد فسبازيان ثم صارت «مستعمرة» رومانية في عهد تراجان سنة 109م. وُلد فيها الإمبراطور سبتيموس سيفيروس عام 145م، وحين اعتلى العرش سنة 193م أغدق على مدينته برنامج بناء ضخمًا جعلها من أبهى مدن الإمبراطورية، قبل أن تتراجع في العهدين الوندالي والبيزنطي وتطمرها الرمال حتى كشفتها حفريات القرن العشرين.',
      'Leptis was founded by the Phoenicians around the 7th century BC as a trading harbour at the mouth of Wadi Lebda, passed under Carthage, and entered Rome’s orbit after 146 BC. It became a municipium under Vespasian and a Roman colonia under Trajan in AD 109. Emperor Septimius Severus was born here in AD 145; after taking the throne in 193 he lavished a vast building programme on his home town. The city declined under the Vandals and Byzantines, and drifting sand buried it until 20th-century excavations brought it back to light.'
    ),
    (
      'شُيّدت المدينة من الحجر الجيري المحلي وزُيّنت برخام وغرانيت مستوردَين من آسيا الصغرى ومصر واليونان. من روائعها السوق (8 ق.م) بأكشاكه الدائرية، والمسرح الذي أهداه أنوبال روفوس مطلع القرن الأول الميلادي، وحمامات هادريان المزودة بنظام تدفئة أرضية (هيبوكوست)، والمنتدى والبازيليكا السيفيريان، والشارع المعمّد، والنيمفيوم، وميناء ضخم بأرصفة ومنارة. وقد حمى سدٌّ على وادي لبدة المدينةَ من السيول، بينما زوّدتها قناة مائية بالماء العذب.',
      'The city was built of local limestone and dressed in marble and granite imported from Asia Minor, Egypt and Greece. Highlights include the market of 8 BC with its round kiosks, the theatre donated by Annobal Rufus in the early 1st century AD, the Hadrianic Baths with underfloor hypocaust heating, the Severan Forum and Basilica, the colonnaded street, the great nymphaeum, and an artificial harbour with quays and a lighthouse. A dam on Wadi Lebda shielded the city from flash floods while an aqueduct brought fresh water.'
    ),
    (
      'أُدرجت لبدة الكبرى في قائمة اليونسكو للتراث العالمي عام 1982 بوصفها من أكمل نماذج التخطيط العمراني الروماني في العالم، ثم وُضعت عام 2016 مع سائر المواقع الليبية على قائمة التراث المهدد بالخطر. وتواجه اليوم تحديات التعرية الساحلية والأملاح البحرية والنمو النباتي، ما يجعل التوثيق الرقمي والترميم الدوري أولوية لحماية هذه الشهادة الفريدة على عبقرية شمال إفريقيا الرومانية.',
      'Leptis Magna was inscribed on the UNESCO World Heritage List in 1982 as one of the most complete examples of Roman urban planning anywhere, and in 2016 it joined Libya’s other sites on the List of World Heritage in Danger. Coastal erosion, sea salts and invasive vegetation remain constant threats, which makes digital documentation and regular conservation a priority for this unique witness to the genius of Roman North Africa.'
    ),
  ],
  'cyrene': [
    (
      'أسس قورينا نحو عام 631 ق.م مستوطنون إغريق من جزيرة ثيرا (سانتوريني) بقيادة باتوس الأول، فحكمتها الأسرة الباتية قرابة قرنين. ازدهرت بتجارة نبات السلفيوم النادر حتى صار رمزًا على عملتها، ثم خضعت للبطالمة بعد الإسكندر، وأصبحت عام 74 ق.م جزءًا من ولاية «كريت وقورينائية» الرومانية. أنجبت المدينة الفيلسوف أريستيبوس مؤسس المدرسة القورينائية، والشاعر كاليماخوس، والعالِم إراتوستينس الذي قاس محيط الأرض. تضررت بشدة في الثورة اليهودية عام 115م ثم في زلزال عام 365م.',
      'Cyrene was founded around 631 BC by Greek settlers from the island of Thera (Santorini) led by Battus I, whose Battiad dynasty ruled for nearly two centuries. It grew rich on the rare silphium plant, which became the emblem of its coins, passed to the Ptolemies after Alexander, and in 74 BC became part of the Roman province of Crete and Cyrenaica. The city produced the philosopher Aristippus, founder of the Cyrenaic school, the poet Callimachus and Eratosthenes, who measured the Earth’s circumference. It was badly damaged in the Jewish revolt of AD 115 and by the earthquake of 365.'
    ),
    (
      'تقوم المدينة على مدرجات الجبل الأخضر على ارتفاع نحو 600 متر فوق البحر، وقد بُنيت من الحجر الجيري المحلي. يعد معبد زيوس الدوري (أواخر القرن السادس ق.م) من أكبر المعابد الإغريقية، وتُقارن مقاييسه بالبارثينون، وقد أعيد رفع كثير من أعمدته بأعمال الترميم الحديثة. وإلى جانبه حرم أبولون عند النبع المقدس، والأغورا ومبانيها العامة، والمسرح، ومقبرة واسعة من القبور المنحوتة في الصخر تمتد كيلومترات حول المدينة، بينما ربطها طريق بمرفئها أبولونيا على الساحل.',
      'The city spreads over terraces of the Jebel Akhdar some 600 m above the sea and was built of local limestone. The Doric Temple of Zeus, from the late 6th century BC, is one of the largest Greek temples ever built, comparable in size to the Parthenon, and modern restoration has raised many of its columns again. Around it lie the Sanctuary of Apollo by the sacred spring, the Agora and its public buildings, the theatre, and a vast necropolis of rock-cut tombs stretching for kilometres, while a road linked the city to its port at Apollonia.'
    ),
    (
      'أُدرجت قورينا في قائمة اليونسكو للتراث العالمي عام 1982 بوصفها من أهم المدن الإغريقية خارج بلاد اليونان، ومن مراكز الفكر والطب والفلسفة في العالم القديم. وأُدرجت عام 2016 على قائمة التراث المهدد بسبب الزحف العمراني والبناء غير المرخص والإهمال، ما يجعل حماية حدود الموقع ومقبرته الشاسعة مهمة عاجلة للأجيال القادمة.',
      'Cyrene was inscribed on the UNESCO World Heritage List in 1982 as one of the most important Greek cities outside Greece itself and a centre of thought, medicine and philosophy in the ancient world. In 2016 it was placed on the List of World Heritage in Danger because of urban encroachment, unlicensed building and neglect, making the protection of the site’s boundaries and its immense necropolis an urgent task for future generations.'
    ),
  ],
  'sabratha': [
    (
      'نشأت صبراتة محطةً تجارية فينيقية نحو القرن الخامس قبل الميلاد، تستقبل قوافل الصحراء المحمّلة بالعاج والذهب لتنقلها عبر البحر. خضعت لنفوذ قرطاج ثم للمملكة النوميدية، قبل أن تصبح مدينة رومانية مزدهرة بلغت أوجها في القرنين الثاني والثالث الميلاديين. وفي العهد البيزنطي أعاد الإمبراطور جستنيان تحصينها وشيّد فيها كنيسة مزدانة بالفسيفساء، ثم تراجعت تدريجيًا بعد القرن السابع حتى غطتها الرمال.',
      'Sabratha began as a Phoenician trading post around the 5th century BC, receiving Saharan caravans laden with ivory and gold for shipment across the sea. It came under Carthage and then the Numidian kingdom before becoming a prosperous Roman city that peaked in the 2nd and 3rd centuries AD. In the Byzantine period Emperor Justinian refortified it and built a church floored with mosaics; the town then slowly declined after the 7th century until sand covered it.'
    ),
    (
      'أشهر معالمها المسرح الروماني المشيّد أواخر القرن الثاني الميلادي، بواجهة مسرحية (سكاينا فرونس) من ثلاثة طوابق يبلغ ارتفاعها نحو 25 مترًا وتضم أكثر من مئة عمود كورنثي، أعاد علماء الآثار الإيطاليون تركيبها في ثلاثينيات القرن العشرين. وتتسع مدرجاته لنحو خمسة آلاف متفرج، وتزين مقدمة المنصة نقوش بارزة لمشاهد أسطورية ومسرحية. بُنيت المدينة من الحجر الرملي الذهبي المحلي، وتضم أيضًا معبد إيزيس المطل على البحر، ومعبد سيرابيس، والضريح البونيقي ذا الطراز الهلنستي.',
      'Its most famous monument is the Roman theatre of the late 2nd century AD, whose three-storey stage front (scaenae frons) rises about 25 m and carries more than a hundred Corinthian columns, reassembled by Italian archaeologists in the 1930s. The cavea seated around 5,000 spectators, and the stage podium is carved with mythological and theatrical reliefs. The city was built from local golden sandstone and also preserves the seaside Temple of Isis, the Temple of Serapis and a Punic mausoleum in Hellenistic style.'
    ),
    (
      'أُدرجت صبراتة في قائمة التراث العالمي لليونسكو عام 1982 لما تقدمه من شهادة فريدة على التمازج بين الثقافات البونيقية والنوميدية والرومانية على ساحل المتوسط، ويعد مسرحها من أجمل المسارح الرومانية الباقية. وُضعت على قائمة التراث المهدد عام 2016، وتحتاج واجهاتها الرملية الرقيقة إلى مراقبة مستمرة لمقاومة الرياح المالحة والتعرية.',
      'Sabratha was inscribed on the UNESCO World Heritage List in 1982 as a unique testimony to the blending of Punic, Numidian and Roman cultures on the Mediterranean shore, and its theatre is among the finest surviving Roman theatres anywhere. Placed on the List of World Heritage in Danger in 2016, its delicate sandstone facades require continuous monitoring against salt-laden winds and erosion.'
    ),
  ],
  'acacus': [
    (
      'تقع جبال تادرارت أكاكوس جنوب غرب ليبيا قرب مدينة غات وعلى حدود الجزائر، وتحفظ آلاف الرسوم والنقوش الصخرية التي يمتد تاريخها من نحو 12 ألف سنة قبل الميلاد حتى القرن الأول الميلادي. وقد قسّمها الباحثون إلى مراحل متتالية: مرحلة الحيوانات البرية الكبيرة، ومرحلة «الرؤوس المستديرة»، والمرحلة الرعوية، ثم مرحلتا الحصان والجمل. وفي ملجأ «وان موهجاج» عُثر عام 1958 على مومياء طفل يقدَّر عمرها بأكثر من خمسة آلاف عام.',
      'The Tadrart Acacus range lies in south-western Libya near Ghat on the Algerian border and preserves thousands of rock paintings and engravings dating from around 12,000 BC to the 1st century AD. Researchers divide them into successive phases: the Large Wild Fauna, the “Round Head”, the Pastoral, and finally the Horse and Camel periods. In the Uan Muhuggiag rock shelter, a child’s mummy more than five thousand years old was discovered in 1958.'
    ),
    (
      'هذه الكتلة الجبلية من الحجر الرملي نحتتها الرياح والمياه عبر ملايين السنين فشكّلت أقواسًا طبيعية مذهلة مثل قوس أفزجار، وأوديةً عميقة وأبراجًا صخرية تحيط بها كثبان ذهبية. استخدم الفنانون القدامى أصباغ المغرة المستخرجة من أكاسيد الحديد ممزوجة بمواد عضوية، ورسموا في الملاجئ الصخرية المحمية من الشمس والمطر، ما ساعد على بقاء الألوان آلاف السنين.',
      'This sandstone massif was sculpted by wind and water over millions of years into spectacular natural arches such as Fozzigiaren, deep canyons and rock towers surrounded by golden dunes. Ancient artists used ochre pigments made from iron oxides mixed with organic binders, and painted inside rock shelters protected from sun and rain, which is why the colours have survived for thousands of years.'
    ),
    (
      'أُدرجت مواقع الفن الصخري في تادرارت أكاكوس في قائمة اليونسكو عام 1985، فهي سجل مصوّر نادر لتحول الصحراء الكبرى من سافانا خضراء تجوبها الزرافات والفيلة إلى صحراء جافة، ولتطور حياة الإنسان من الصيد إلى الرعي. وأُدرجت عام 2016 على قائمة التراث المهدد بسبب التخريب والكتابة على الرسوم، ما يستدعي الزيارة المصحوبة بمرشدين وعدم لمس اللوحات.',
      'The rock-art sites of the Tadrart Acacus were inscribed on the UNESCO list in 1985 as a rare illustrated record of the Sahara’s transformation from a green savanna roamed by giraffes and elephants into dry desert, and of human life evolving from hunting to herding. They were added to the List in Danger in 2016 because of vandalism and graffiti, so visits should always be guided and the paintings never touched.'
    ),
  ],
  'ghadames': [
    (
      'غدامس، «لؤلؤة الصحراء»، واحة عريقة عُرفت عند الرومان باسم «كيداموس»، وأقاموا فيها حامية بعد حملة كورنيليوس بالبوس عام 19 ق.م. صارت أسقفية في العهد البيزنطي، ثم دخلت الإسلام في القرن السابع الميلادي، وغدت لقرون محطة رئيسية لتجارة القوافل العابرة للصحراء بين ساحل المتوسط وتمبكتو وكانو وبلاد السودان. وفي ثمانينيات القرن العشرين انتقل معظم سكانها إلى المدينة الحديثة، وبقيت المدينة القديمة شاهدة على نمط حياة فريد.',
      'Ghadames, the “Pearl of the Desert”, is an ancient oasis the Romans knew as Cydamus, garrisoned after the campaign of Cornelius Balbus in 19 BC. It became a bishopric in Byzantine times, embraced Islam in the 7th century, and for centuries was a key hub of the trans-Saharan caravan trade linking the Mediterranean coast with Timbuktu, Kano and the lands of the Sudan. In the 1980s most inhabitants moved to the modern town, leaving the old city as a witness to a unique way of life.'
    ),
    (
      'بُنيت البيوت من الطوب اللبن وجذوع النخيل وطُليت بالجير الأبيض، ووُزعت عموديًا: الطابق الأرضي للتخزين، والأوسط لمعيشة الأسرة، والأسطح المتصلة ممرات خاصة للنساء يتنقلن عبرها بين البيوت. أما الأزقة فمسقوفة في معظمها تتخللها فتحات للضوء والتهوية، فتبقى باردة في حر الصيف. ووزع أهلها مياه «عين الفرس» على البساتين عبر قنوات دقيقة وبنظام توقيت تقليدي يُعرف بـ«القادوس»، في مثال رائع على الهندسة الصحراوية المستدامة.',
      'Houses were built of mudbrick and palm trunks and whitewashed with lime, organised vertically: the ground floor for storage, the middle floor for family life, and interconnected rooftops forming private pathways along which women moved from house to house. Most alleys are roofed, with openings for light and ventilation, so they stay cool in summer heat. The water of the Ain al-Faras spring was shared among the gardens through fine channels timed with a traditional system called the qadus, a remarkable example of sustainable desert engineering.'
    ),
    (
      'أُدرجت مدينة غدامس القديمة في قائمة اليونسكو للتراث العالمي عام 1986 بوصفها «من أقدم المدن قبل الصحراوية وأحد أبرز نماذج المستوطنات التقليدية». وتعكس عمارتها التكيف العبقري مع المناخ القاسي وتماسك المجتمع الأمازيغي والعربي فيها. أُدرجت على قائمة التراث المهدد عام 2016، ويحتاج طوبها اللبن إلى صيانة دورية بالمواد التقليدية بعد هجرة السكان.',
      'The Old Town of Ghadames was inscribed on the UNESCO World Heritage List in 1986 as “one of the oldest pre-Saharan cities and an outstanding example of a traditional settlement.” Its architecture reflects an ingenious adaptation to a harsh climate and the cohesion of its Amazigh and Arab community. Listed as endangered in 2016, its mudbrick fabric needs regular upkeep with traditional materials now that its residents have moved out.'
    ),
  ],
  'redcastle': [
    (
      'تقوم السرايا الحمراء على الطرف الشمالي الشرقي لمدينة طرابلس القديمة فوق موقع استُخدم منذ العصر الروماني. حصّنها الإسبان بعد احتلالهم المدينة عام 1510، ثم فرسان القديس يوحنا بين 1530 و1551، حتى استعادها العثمانيون عام 1551. وفي عهد الأسرة القرمانلية (1711–1835) صارت قصرًا ومقرًا للحكم توسع وازدان بالأفنية، ثم استخدمها الإيطاليون مقرًا إداريًا، وتحولت لاحقًا إلى المتحف الوطني الليبي.',
      'The Red Castle stands at the north-eastern tip of Tripoli’s old city on a site used since Roman times. The Spanish fortified it after taking the city in 1510, followed by the Knights of St John between 1530 and 1551, until the Ottomans recaptured it in 1551. Under the Karamanli dynasty (1711–1835) it became a palace and seat of government, enlarged and embellished with courtyards; the Italians later used it as an administrative headquarters, and it eventually became Libya’s national museum.'
    ),
    (
      'يتكون القصر من متاهة من الأفنية والممرات والأبراج والقاعات المتراكبة عبر العصور، بُنيت من الحجر والملاط الجيري بجدران سميكة مطلة على البحر. ويضم المتحف أجنحة على عدة طوابق تستعرض تاريخ ليبيا من عصور ما قبل التاريخ والفن الصخري، مرورًا بالحضارات الفينيقية والإغريقية والرومانية بفسيفسائها وتماثيلها، ووصولًا إلى العهد الإسلامي بمخطوطاته وخزفه وأزيائه التقليدية.',
      'The palace is a labyrinth of courtyards, passages, towers and halls layered over the centuries, built of stone and lime mortar with massive walls facing the sea. Its museum galleries span several floors, presenting Libya’s history from prehistory and rock art, through the Phoenician, Greek and Roman civilisations with their mosaics and sculpture, to the Islamic era with its manuscripts, ceramics and traditional costume.'
    ),
    (
      'السرايا الحمراء رمز لطرابلس ولتعاقب الحضارات على أرض ليبيا، إذ تحمل جدرانها آثار الرومان والإسبان والفرسان والعثمانيين والقرمانليين. ومتحفها من أغنى متاحف شمال إفريقيا، وقد صُممت قاعاته الحديثة بالتعاون مع اليونسكو. وتسعى جهود الصون إلى حماية مقتنياته وإعادة فتحها للزوار بصورة آمنة ومستدامة.',
      'The Red Castle is a symbol of Tripoli and of the succession of civilisations on Libyan soil, its walls bearing traces of Romans, Spaniards, Knights, Ottomans and Karamanlis. Its museum is one of the richest in North Africa, with modern galleries designed in cooperation with UNESCO. Conservation efforts aim to safeguard its collections and keep them safely and sustainably open to visitors.'
    ),
  ],
  'marcus': [
    (
      'شُيّد القوس عامي 163–164م في مدينة «أويا» الرومانية (طرابلس اليوم)، بتمويل من القاضي المحلي غايوس كالبورنيوس سلسيانوس، وأُهدي إلى الإمبراطورين ماركوس أوريليوس ولوكيوس فيروس احتفاءً بانتصاراتهما على البارثيين. وهو المعلم الروماني الوحيد الذي بقي قائمًا من أويا القديمة، وقد طُمر جزء منه قرونًا وأحاطت به المباني، حتى كشفته أعمال التنقيب والترميم في النصف الأول من القرن العشرين.',
      'The arch was built in AD 163–164 in the Roman city of Oea (modern Tripoli), funded by the local magistrate Gaius Calpurnius Celsianus and dedicated to the emperors Marcus Aurelius and Lucius Verus to celebrate their victories over the Parthians. It is the only Roman monument of ancient Oea still standing; for centuries it was partly buried and hemmed in by buildings until excavation and restoration in the first half of the 20th century revealed it again.'
    ),
    (
      'القوس من طراز «الرباعي الواجهات» (تترابيلون)، أقيم عند تقاطع الشارعين الرئيسيين للمدينة، وبُني من كتل رخامية ضخمة متقنة الرصف. يعلوه من الداخل سقف حجري مثمن مزخرف بالنقوش، وتزدان واجهاته بمنحوتات بارزة لأبولو ومينيرفا حاميي المدينة، وبمشاهد الغنائم والأسرى، ونقش لاتيني يخلد الإهداء.',
      'It is a four-way arch (tetrapylon) raised at the crossing of the city’s two main streets and built of massive, precisely fitted marble blocks. Inside, an octagonal stone vault is richly carved, while the facades bear reliefs of Apollo and Minerva, the city’s protectors, scenes of trophies and captives, and a Latin inscription recording the dedication.'
    ),
    (
      'يُعد القوس أقدم معالم طرابلس القائمة وحلقة الوصل بين ماضيها الروماني ومدينتها الإسلامية القديمة التي نمت حوله. وهو مثال نادر على الأقواس الرباعية في شمال إفريقيا، ويحتاج رخامه المعرّض لرطوبة البحر وتلوث المدينة إلى تنظيف وحماية دوريين.',
      'The arch is the oldest standing monument in Tripoli and a link between its Roman past and the Islamic old city that grew up around it. It is a rare example of a four-way arch in North Africa, and its marble, exposed to sea humidity and urban pollution, requires regular cleaning and protection.'
    ),
  ],
  'ptolemais': [
    (
      'نشأت طلميثة مرفأً لمدينة برقة الإغريقية نحو القرن السادس قبل الميلاد، ثم أعاد البطالمة تأسيسها في القرن الثالث ق.م وسموها «بطوليمايس» نسبة إلى ملوكهم. كانت إحدى مدن «البنتابوليس» الخمس في إقليم قورينائية، وفي أواخر العصر الروماني صارت عاصمة لولاية ليبيا العليا بعد تراجع قورينا. وفي القرن الخامس الميلادي كان أسقفها الفيلسوف سينيسيوس القوريني.',
      'Ptolemais began as the harbour of the Greek city of Barca around the 6th century BC and was refounded by the Ptolemies in the 3rd century BC, who named it after their royal house. It was one of the five cities of the Cyrenaican Pentapolis, and in the late Roman period it became capital of the province of Upper Libya as Cyrene declined. In the 5th century AD its bishop was the philosopher Synesius of Cyrene.'
    ),
    (
      'خُططت المدينة على النظام الشبكي الهيبودامي بشوارع متعامدة، ومن أبرز معالمها «قصر الأعمدة»، وهو مسكن فخم من العصر الهلنستي الروماني يتوسطه فناء معمّد وحوض ماء. وتحت ساحة المنتدى صهاريج مقببة ضخمة كانت تخزن المياه الواردة عبر قناة من الجبل، إلى جانب الأوديون، وفيلا الفصول الأربعة بفسيفسائها، والكنائس البيزنطية المحصنة، وبوابة توخيرة.',
      'The city was laid out on a Hippodamian grid of right-angled streets. Its most celebrated monument is the Palace of the Columns, a luxurious Hellenistic-Roman residence built around a colonnaded courtyard and pool. Beneath the forum lie huge vaulted cisterns that stored water brought by aqueduct from the hills, alongside the Odeon, the Villa of the Four Seasons with its mosaics, fortified Byzantine churches and the Tocra Gate.'
    ),
    (
      'تعد طلميثة من أغنى مواقع برقة الأثرية، وتكشف بوضوح انتقال الإقليم من العصر الإغريقي إلى الروماني ثم البيزنطي. ويعرض متحفها الصغير فسيفساء وتماثيل ونقوشًا مهمة، فيما تتطلب أطلالها الساحلية حماية من زحف العمران والتعرية البحرية.',
      'Ptolemais is one of the richest archaeological sites in Cyrenaica, clearly showing the region’s passage from the Greek to the Roman and Byzantine eras. Its small museum displays important mosaics, sculpture and inscriptions, while its coastal ruins need protection from urban sprawl and marine erosion.'
    ),
  ],
  'apollonia': [
    (
      'أبولونيا هي ميناء قورينا الإغريقي، أُنشئ في القرن السابع قبل الميلاد على بعد نحو عشرين كيلومترًا من المدينة الأم، وارتبط بها بطريق صاعد عبر الجبل الأخضر. ازدهرت في العصرين الهلنستي والروماني، ثم صارت في العهد البيزنطي (القرنين الخامس والسادس) عاصمة إقليمية باسم «سوزوسا»، ومنه جاء اسم مدينة سوسة الحالية.',
      'Apollonia was the Greek port of Cyrene, founded in the 7th century BC about twenty kilometres from its mother city and linked to it by a road climbing the Jebel Akhdar. It flourished in Hellenistic and Roman times, and in the Byzantine era (5th–6th centuries) became a provincial capital under the name Sozusa, the origin of the modern town’s name, Susa.'
    ),
    (
      'أدى هبوط الساحل بفعل الزلازل إلى غمر جزء كبير من الميناء القديم بأرصفته وأحواض سفنه تحت الماء، فصار موقعًا مهمًا للآثار الغارقة. وعلى اليابسة تبرز أسوار هلنستية، والمسرح الإغريقي المنحوت في التل المطل على البحر خارج الأسوار، وثلاث كنائس بيزنطية (الشرقية والغربية والوسطى) بأعمدتها الرخامية المعرقة، وقصر الحاكم البيزنطي.',
      'Earthquake-driven subsidence of the coast has submerged much of the ancient harbour, with its quays and ship sheds, making it an important underwater archaeology site. On land stand Hellenistic walls, a Greek theatre cut into the hillside facing the sea outside the walls, three Byzantine churches (East, West and Central) with veined marble columns, and the palace of the Byzantine governor.'
    ),
    (
      'تكشف أبولونيا الدور البحري الحيوي الذي ربط قورينا بموانئ المتوسط، وتجمع في مشهد واحد آثار البر والبحر. ويجعلها موقعها الساحلي الخلاب ومبانيها الكنسية المميزة من أجمل مواقع الجبل الأخضر، لكنها تتأثر بارتفاع الأمواج والأملاح، ما يستدعي رصدًا ساحليًا مستمرًا.',
      'Apollonia reveals the vital maritime role that connected Cyrene with Mediterranean ports, combining land and underwater remains in a single landscape. Its stunning coastal setting and distinctive churches make it one of the most beautiful sites of the Jebel Akhdar, but rising waves and salt affect it, calling for continuous coastal monitoring.'
    ),
  ],
  'qasralhaj': [
    (
      'يقع قصر الحاج في سفوح جبل نفوسة غرب ليبيا، ويُنسب بناؤه في القرن الثاني عشر الميلادي إلى الشيخ عبد الله أبو جطلة. وهو من «القصور» الأمازيغية، أي مخازن الغلال الجماعية المحصنة التي كانت القرى الجبلية تودع فيها محاصيلها من القمح والشعير وزيت الزيتون، وتحرسها من الجفاف والغارات.',
      'Qasr al-Hajj stands on the slopes of the Nafusa Mountains in western Libya; its construction in the 12th century is attributed to Sheikh Abdullah Abu Jatla. It is one of the Amazigh ksour: fortified communal granaries where mountain villages stored their wheat, barley and olive oil, safeguarding them from drought and raids.'
    ),
    (
      'بُني القصر في شكل دائري حول فناء مركزي، من الحجر والجص وجذوع النخيل، وتتراكب غرفه في طوابق متعددة تصل إليها درجات حجرية بارزة من الجدران. ويُروى أن عدد غرفه 114 غرفة بعدد سور القرآن الكريم، ولكل أسرة غرفتها الخاصة، وللقصر بوابة واحدة يحرسها أمين يدير شؤون التخزين، فيما تحافظ الجدران السميكة على برودة الداخل واستقرار حرارته.',
      'The granary is circular, built around a central courtyard from stone, gypsum and palm trunks, with storage cells stacked over several levels and reached by stone steps projecting from the walls. Tradition holds that it has 114 rooms, the number of chapters in the Qur’an, each belonging to a family; a single gate was guarded by a trustee who managed the stores, while thick walls kept the interior cool and stable in temperature.'
    ),
    (
      'يجسد قصر الحاج نظامًا تكافليًا فريدًا للأمن الغذائي عند أمازيغ جبل نفوسة، ويشبه قصورًا شقيقة مثل نالوت وكاباو. وهو من أفضل نماذج العمارة الشعبية الليبية حفظًا، ويستقطب الزوار والباحثين في التراث المعماري، ويحتاج إلى ترميم تقليدي يحترم مواده الأصلية.',
      'Qasr al-Hajj embodies a unique cooperative system of food security among the Amazigh of the Nafusa Mountains, resembling sister granaries such as Nalut and Kabaw. It is one of the best-preserved examples of Libyan vernacular architecture, attracting visitors and researchers, and it requires traditional restoration that respects its original materials.'
    ),
  ],
  'garama': [
    (
      'كانت جرمة عاصمة مملكة الجرمنتيين في وادي الآجال بفزان، وهي حضارة صحراوية ذكرها هيرودوت في القرن الخامس قبل الميلاد. ازدهرت المدينة بين القرن الأول قبل الميلاد والقرن الخامس الميلادي، وواجهت الرومان الذين أرسلوا إليها حملة كورنيليوس بالبوس عام 19 ق.م، ثم تعاملت معهم تجاريًا. وتراجعت المملكة مع جفاف المياه الجوفية، وفي العصر الإسلامي قامت فوق أطلالها بلدة جرمة القديمة.',
      'Garama was the capital of the Garamantian kingdom in the Wadi al-Ajal of Fezzan, a Saharan civilisation described by Herodotus in the 5th century BC. The city flourished from the 1st century BC to the 5th century AD, confronted Rome, which sent the expedition of Cornelius Balbus against it in 19 BC, and later traded with the empire. The kingdom declined as groundwater dried up, and in the Islamic period the old town of Germa rose on its ruins.'
    ),
    (
      'برع الجرمنتيون في هندسة «الفقارات»، وهي قنوات ري جوفية طويلة تنقل المياه من الطبقات الجوفية إلى الحقول دون أن تتبخر، فزرعوا القمح والشعير والنخيل في قلب الصحراء. وبنوا بيوتهم من الطوب اللبن والحجر، وخلفوا آلاف المقابر بينها قبور على شكل أهرامات صغيرة، وتظهر في أطلال جرمة القديمة جدران طينية عالية وأزقة متعرجة.',
      'The Garamantes excelled at building foggaras, long underground channels that carried groundwater to the fields without evaporation, allowing them to grow wheat, barley and date palms in the heart of the desert. They built in mudbrick and stone and left thousands of tombs, including small pyramid tombs, while the ruins of old Germa preserve tall mud walls and winding lanes.'
    ),
    (
      'تُعد الحضارة الجرمنتية من أوائل المجتمعات الحضرية في الصحراء الكبرى، وحلقة وصل تجارية بين إفريقيا جنوب الصحراء والمتوسط. وقد كشفت بعثات أثرية دولية عن أسرار زراعتها وتجارتها، ويحتاج الطوب اللبن في جرمة إلى صيانة عاجلة أمام الرياح والأمطار النادرة.',
      'The Garamantian civilisation was one of the first urban societies of the Sahara and a trading link between sub-Saharan Africa and the Mediterranean. International archaeological missions have revealed the secrets of its farming and commerce, and Germa’s mudbrick needs urgent maintenance against wind and the rare rains.'
    ),
  ],
  'silin': [
    (
      'فيلا سيلين قصر ريفي روماني فاخر يطل على البحر غرب لبدة الكبرى قرب الخمس، يعود إلى القرن الثاني الميلادي، حين كانت النخبة الثرية في الإقليم تبني مساكن ساحلية للراحة والاستجمام. كُشف عنها في سبعينيات القرن العشرين، فظهرت في حالة حفظ استثنائية بجدرانها وأرضياتها، لتصبح من أهم الفيلات الرومانية في شمال إفريقيا.',
      'Villa Silin is a luxurious Roman seaside villa west of Leptis Magna near Khoms, dating to the 2nd century AD, when the province’s wealthy elite built coastal residences for leisure. Uncovered in the 1970s, it emerged in an exceptional state of preservation, walls and floors intact, and is now among the most important Roman villas in North Africa.'
    ),
    (
      'تضم الفيلا قاعات استقبال وغرفًا وأروقة تطل على البحر، وجناحًا خاصًا للحمامات بأحواضه الساخنة والباردة ونظام التدفئة تحت الأرضية. وتزين أرضياتها فسيفساء ملونة دقيقة تصور مشاهد من الحلبة وسباقات العربات والحياة البحرية والزخارف الهندسية، إلى جانب بقايا رسوم جدارية، وهو أسلوب فني يشاركه فيلات ساحلية مجاورة مثل فيلا النيل في لبدة وفيلا زليتن.',
      'The villa has reception halls, rooms and porticoes overlooking the sea, plus a private bath suite with hot and cold pools and underfloor heating. Its floors are covered in fine polychrome mosaics showing scenes of the arena, chariot racing, marine life and geometric patterns, along with remains of wall paintings, an artistic style shared with neighbouring seaside villas such as the Villa of the Nile at Leptis and the Zliten villa.'
    ),
    (
      'تمنح فيلا سيلين صورة حية عن الحياة اليومية والذوق الفني لطبقة الأثرياء في ليبيا الرومانية، وتعد فسيفساؤها من أروع ما بقي في مكانه الأصلي. ولأن الفسيفساء الأرضية شديدة الحساسية للرطوبة والأملاح والأقدام، تُعرض بحذر وتحت إشراف، مع حاجة دائمة إلى تغطية واقية وترميم متخصص.',
      'Villa Silin offers a vivid picture of the daily life and artistic taste of the wealthy in Roman Libya, and its mosaics are among the finest still in their original place. Because floor mosaics are highly sensitive to humidity, salts and foot traffic, they are shown carefully under supervision, with a constant need for protective covering and specialist conservation.'
    ),
  ],
  'gaberoun': [
    (
      'تقع بحيرة قبرعون في قلب بحر رمال أوباري في فزان، ضمن مجموعة من نحو عشرين بحيرة صحراوية أشهرها أم الماء ومندرة. وهي بقايا مسطحات مائية أوسع عرفتها الصحراء الكبرى في العصور المطيرة قبل آلاف السنين، وتغذيها المياه الجوفية. سكنها شعب «الدواودة» الذين عاشوا على النخيل وعلى جمع قشريات دقيقة من البحيرات المالحة، حتى انتقلوا إلى قرية حديثة في أواخر القرن العشرين.',
      'Lake Gaberoun lies in the heart of the Ubari Sand Sea in Fezzan, one of about twenty desert lakes, the best known being Umm al-Maa and Mandara. They are remnants of the larger water bodies that covered the Sahara during humid periods thousands of years ago and are fed by groundwater. The Dawada people lived here on dates and on tiny brine shrimp harvested from the salty lakes, until they moved to a modern village in the late 20th century.'
    ),
    (
      'مياه البحيرة شديدة الملوحة والقلوية، يطفو فيها السابح بسهولة، وتحيط بها أحزمة من النخيل والقصب تحتضنها كثبان ذهبية يتجاوز ارتفاع بعضها مئة متر. ولا تزال على ضفافها بقايا القرية القديمة المبنية من الطوب اللبن وسعف النخيل، في مثال بسيط على عمارة التكيف مع البيئة الرملية.',
      'The lake’s water is extremely salty and alkaline, so swimmers float easily, and it is ringed by palms and reeds embraced by golden dunes, some more than a hundred metres high. On its shore stand the remains of the old village built of mudbrick and palm fronds, a simple example of architecture adapted to a sandy environment.'
    ),
    (
      'تمثل بحيرات أوباري مشهدًا طبيعيًا نادرًا يجمع الماء والرمل والنخيل، وتحمل ذاكرة مجتمع صحراوي فريد. وهي وجهة سياحية وبيئية مهمة، تحتاج إلى حماية من التلوث وانخفاض منسوب المياه الجوفية، ومن السياحة غير المنظمة.',
      'The Ubari lakes are a rare natural landscape uniting water, sand and palms and carry the memory of a unique desert community. They are an important tourist and ecological destination that needs protection from pollution, falling groundwater levels and unregulated tourism.'
    ),
  ],
  'waw': [
    (
      'واو الناموس بركان خامد في قلب الصحراء الليبية جنوب فزان، يُعد من أبعد البراكين عن العمران على وجه الأرض. يعني اسمه «واحة البعوض» لكثرة البعوض حول بحيراته. ويرى الجيولوجيون أنه بركان حديث نسبيًا يعود نشاطه إلى عصر الهولوسين، وقد عرفه المسافرون في الصحراء علامةً سوداء مميزة وسط الرمال الفاتحة.',
      'Waw an Namus is a dormant volcano in the heart of the Libyan desert in southern Fezzan, one of the most remote volcanoes on Earth. Its name means “oasis of mosquitoes”, after the insects that swarm around its lakes. Geologists consider it relatively young, with activity during the Holocene, and desert travellers have long known it as a striking black landmark amid pale sands.'
    ),
    (
      'يتكون البركان من فوهة كبيرة (كالديرا) يبلغ قطرها نحو أربعة كيلومترات، يتوسطها مخروط من الرماد البركاني، وتحيط به بحيرات صغيرة بألوان متباينة بين الأزرق والأخضر والأحمر بسبب الطحالب والمعادن الذائبة. وقد نثر البركان رمادًا أسود في دائرة واسعة حوله، يتناقض بشدة مع الرمال الصفراء فيُرى بوضوح من الفضاء.',
      'The volcano consists of a large caldera about four kilometres across with a cone of volcanic ash at its centre, surrounded by small lakes whose colours range from blue and green to red because of algae and dissolved minerals. It scattered black ash over a wide circle around it, contrasting so sharply with the yellow sands that it is clearly visible from space.'
    ),
    (
      'واو الناموس كنز جيولوجي وبيئي نادر، إذ تجمع واحة حية ومياهًا عذبة ومالحة في أقسى بيئة صحراوية. وهي محمية طبيعية تستحق الحماية من آثار المركبات والنفايات، وتشكل مختبرًا مفتوحًا لدراسة البراكين وتاريخ مناخ الصحراء الكبرى.',
      'Waw an Namus is a rare geological and ecological treasure, sustaining a living oasis with fresh and salty water in one of the harshest desert environments. A natural reserve, it deserves protection from vehicle tracks and litter, and serves as an open laboratory for studying volcanoes and the climate history of the Sahara.'
    ),
  ],
  'medusa': [
    (
      'تزين رؤوس ميدوسا أقواس المنتدى السيفيري في لبدة الكبرى، الذي أمر ببنائه الإمبراطور سبتيموس سيفيروس مطلع القرن الثالث الميلادي وأكمله ابنه كاراكلا. وفي الأسطورة الإغريقية كانت ميدوسا إحدى الغورغونات التي يحول نظرها الناظرين إلى حجر، ولذلك استُخدم رأسها رمزًا لحماية المباني ودرء الشر.',
      'The Medusa heads adorn the arcades of the Severan Forum at Leptis Magna, commissioned by Emperor Septimius Severus in the early 3rd century AD and completed by his son Caracalla. In Greek myth Medusa was one of the Gorgons whose gaze turned onlookers to stone, so her head was used as an emblem to protect buildings and ward off evil.'
    ),
    (
      'نُحتت الرؤوس في ميداليات دائرية كبيرة بين أقواس الرواق المحيط بساحة المنتدى، وتتنوع ملامحها من رأس لآخر في الشعر الأفعواني وتعابير الوجه، ما يدل على براعة نحاتين يُرجح أنهم قدموا من مدرسة أفروديسياس في آسيا الصغرى. وكان الرواق يحيط بساحة واسعة مرصوفة يتصدرها معبد ضخم، بينما تتصل بالمنتدى البازيليكا السيفيرية الشهيرة.',
      'The heads were carved in large round medallions between the arches of the portico surrounding the forum square, each varying in its snake-like hair and facial expression, a sign of master carvers probably trained in the school of Aphrodisias in Asia Minor. The portico framed a vast paved square dominated by a great temple, with the famous Severan Basilica adjoining the forum.'
    ),
    (
      'تُعد رؤوس ميدوسا في لبدة من أشهر روائع النحت الروماني في إفريقيا، وأيقونة بصرية للموقع المدرج في التراث العالمي. ويعرّضها بقاؤها في الهواء الطلق للتآكل وفقدان التفاصيل، لذا يتطلب الحفاظ عليها توثيقًا ثلاثي الأبعاد وتنظيفًا متخصصًا.',
      'The Medusa heads of Leptis are among the most famous masterpieces of Roman sculpture in Africa and a visual icon of the World Heritage site. Remaining in the open air exposes them to weathering and loss of detail, so their preservation calls for 3D documentation and specialist cleaning.'
    ),
  ],
  'severus': [
    (
      'وُلد لوكيوس سبتيموس سيفيروس في لبدة الكبرى في 11 أبريل 145م لأسرة ذات جذور بونيقية، وتدرج في المناصب حتى نودي به إمبراطورًا عام 193م، فكان أول إمبراطور روماني من أصل إفريقي. أسس الأسرة السيفيرية، وخاض حروبًا ضد البارثيين وفي بريطانيا، وتوفي في يورك عام 211م. وزار مسقط رأسه عام 203م، فشهدت لبدة في عهده أعظم نهضة عمرانية في تاريخها.',
      'Lucius Septimius Severus was born at Leptis Magna on 11 April AD 145 into a family of Punic roots and rose through the ranks until he was proclaimed emperor in 193, the first Roman emperor of African origin. He founded the Severan dynasty, fought the Parthians and campaigned in Britain, and died at York in 211. He visited his birthplace in 203, and under his rule Leptis saw the greatest building boom in its history.'
    ),
    (
      'تُخلد صورته في تماثيل نصفية رخامية منتشرة في متاحف العالم، يظهر فيها بلحية كثة وشعر مجعد ورداء عسكري أو عباءة. وفي لبدة أقيم قوسه الرباعي الواجهات عند ملتقى الطريقين الرئيسيين، وزُيّن بنقوش رخامية بارزة تصور موكب النصر والأسرة الإمبراطورية، إلى جانب المنتدى والبازيليكا اللذين بُنيا من الرخام والغرانيت المستورد.',
      'His likeness survives in marble busts in museums worldwide, showing a full beard, curled hair and a military cloak or toga. At Leptis his four-way arch rose at the meeting of the two main roads, adorned with marble reliefs of the triumphal procession and the imperial family, alongside the forum and basilica built of imported marble and granite.'
    ),
    (
      'يمثل سيبتيموس سيفيروس رمزًا لمكانة ليبيا في العالم الروماني، فابن لبدة حكم أعظم إمبراطوريات عصره. وتشهد المنشآت التي أهداها لمدينته على ازدهار شمال إفريقيا، وتعد نقوش قوسه وثيقة فنية وتاريخية تستحق الحماية والدراسة.',
      'Septimius Severus symbolises Libya’s standing in the Roman world: a son of Leptis ruled the greatest empire of his age. The buildings he gave his city bear witness to North Africa’s prosperity, and the reliefs of his arch are an artistic and historical document worthy of protection and study.'
    ),
  ],
  'zliten': [
    (
      'اكتُشفت فسيفساء زليتن عام 1913 في فيلا رومانية فخمة تُعرف بـ«دار بوك عميرة» على الساحل قرب مدينة زليتن، شرق لبدة الكبرى. ويرجح الباحثون أنها تعود إلى القرنين الأول والثاني الميلاديين، وهي اليوم من أبرز مقتنيات متحف السرايا الحمراء في طرابلس.',
      'The Zliten mosaic was discovered in 1913 in a luxurious Roman villa known as Dar Buc Ammera on the coast near Zliten, east of Leptis Magna. Scholars date it to the 1st–2nd centuries AD, and it is now one of the highlights of the Red Castle Museum in Tripoli.'
    ),
    (
      'صُنعت بأسلوب «أوبوس فيرميكولاتوم» بمكعبات حجرية وزجاجية بالغة الصغر تتيح تدرجات لونية دقيقة. ويحيط إطارها الشهير بمشاهد من ألعاب الحلبة: موسيقيون يعزفون على الأرغن المائي والأبواق، ومصارعون بعتادهم، وصيادون للحيوانات، بينما تزين الأقسام الأخرى لوحات للفصول والحياة الريفية والأسماك.',
      'It was made in opus vermiculatum, with tiny stone and glass tesserae that allow subtle colour gradations. Its famous border depicts scenes from the arena games: musicians playing a water organ and horns, gladiators in their armour and animal hunters, while other panels show the seasons, rural life and fish.'
    ),
    (
      'تعد فسيفساء زليتن وثيقة تاريخية فريدة عن الترفيه والموسيقى في العالم الروماني، فهي من أوضح الصور الباقية لآلة الأرغن المائي وأنواع المصارعين. كما تكشف دقة رسم الوجوه والملابس والحيوانات مستوى رفيعًا بلغته ورش الفسيفساء في ليبيا الرومانية. ويحتاج عرضها المتحفي إلى إضاءة وتهوية مدروستين للحفاظ على ألوانها الأصلية.',
      'The Zliten mosaic is a unique historical document of entertainment and music in the Roman world, offering one of the clearest surviving images of the water organ and of gladiator types. Its museum display needs carefully controlled lighting and ventilation to preserve its original colours.'
    ),
  ],
  'ghadames_ms': [
    (
      'احتفظت أسر غدامس وزواياها عبر القرون بمكتبات خاصة من المخطوطات، جمعها علماء وتجار المدينة الذين ربطتهم تجارة القوافل بتمبكتو وكانو وفاس والقاهرة. وتشمل المصاحف وكتب الفقه المالكي والحديث واللغة العربية والفلك والحساب، إضافة إلى الوثائق التجارية والعقود والرسائل التي تكشف تفاصيل الحياة الاقتصادية والاجتماعية.',
      'Over the centuries the families and zawiyas of Ghadames kept private libraries of manuscripts, gathered by the city’s scholars and merchants whose caravan trade linked them to Timbuktu, Kano, Fez and Cairo. They include Qur’ans, works of Maliki jurisprudence, hadith, Arabic grammar, astronomy and arithmetic, as well as commercial documents, contracts and letters that reveal details of economic and social life.'
    ),
    (
      'كُتبت أغلبها بالخط المغربي المميز بانحناءاته واستداراته، على ورق مستورد عبر طرق التجارة، بحبر أسود من السناج والصمغ العربي وحبر ملون للعناوين والتشكيل. وجُلّدت بالجلد المحلي المزخرف، وحُفظت في صناديق داخل البيوت الغدامسية الباردة ذات الجدران الطينية السميكة، ما ساعد على بقائها رغم قسوة المناخ.',
      'Most are written in the distinctive Maghribi script with its sweeping curves, on paper imported along trade routes, in black ink made of soot and gum arabic with coloured inks for headings and vowel marks. They were bound in decorated local leather and kept in chests inside cool Ghadamesi houses with thick mud walls, which helped them survive the harsh climate.'
    ),
    (
      'تشهد مخطوطات غدامس على دور المدينة مركزًا علميًا وتجاريًا في الصحراء الكبرى، وعلى شبكة المعرفة التي امتدت مع القوافل. وتهددها الرطوبة والحشرات والتفرق، لذا تُعد الفهرسة والرقمنة والحفظ في بيئة مضبوطة أولوية لصون هذا الإرث المكتوب.',
      'The Ghadames manuscripts testify to the city’s role as a centre of learning and trade in the Sahara and to the network of knowledge that travelled with the caravans. Humidity, insects and dispersal threaten them, so cataloguing, digitisation and storage in a controlled environment are priorities for safeguarding this written heritage.'
    ),
  ],
  'apollo_cyrene': [
    (
      'حرم أبولون أقدم وأقدس بقعة في قورينا، أقامه المستوطنون الأوائل في القرن السابع قبل الميلاد إلى جوار النبع المقدس «كيري» الذي أعطى المدينة اسمها. بُني معبد أبولون الأول في القرن السادس ق.م، وأعيد بناؤه في القرن الرابع ق.م، ثم رُمم في عهد هادريان بعد الدمار الذي لحق به في الثورة اليهودية عام 115م.',
      'The Sanctuary of Apollo is Cyrene’s oldest and holiest place, established by the first settlers in the 7th century BC beside the sacred spring of Kyre that gave the city its name. The first Temple of Apollo was built in the 6th century BC, rebuilt in the 4th century BC, and restored under Hadrian after the destruction of the Jewish revolt of AD 115.'
    ),
    (
      'يمتد الحرم على مصطبة طبيعية أسفل المدينة، ويضم معبد أبولون الدوري، ومذبحًا طويلًا للقرابين، ومعابد صغيرة لأرتميس وغيرها، وبوابتين إغريقية ورومانية، ونفقًا قديمًا يجلب مياه النبع إلى نافورة أبولون. وعُثر فيه على تماثيل كثيرة لكاهنات وشخصيات بأردية طويلة، يُعرض بعضها في متحف شحات.',
      'The sanctuary spreads over a natural terrace below the city and includes the Doric Temple of Apollo, a long sacrificial altar, smaller temples to Artemis and other deities, Greek and Roman gateways, and an ancient tunnel carrying spring water to the Fountain of Apollo. Many statues of priestesses and robed figures were found here, some displayed in the Shahat museum.'
    ),
    (
      'يجسد الحرم البعد الديني والروحي لقورينا ويضم أقدم آثارها، وهو جزء من موقع التراث العالمي المدرج عام 1982. وتتطلب منحدراته وجدرانه الاستنادية مراقبة مستمرة بسبب الانزلاقات الأرضية ومياه الأمطار، كما تحتاج تماثيله المحفوظة إلى عرض متحفي آمن.',
      'The sanctuary embodies the religious and spiritual dimension of Cyrene and contains its oldest remains, forming part of the World Heritage property inscribed in 1982. Its slopes and retaining walls need constant monitoring because of landslides and rainwater, and its surviving sculptures require secure museum display.'
    ),
  ],
};
