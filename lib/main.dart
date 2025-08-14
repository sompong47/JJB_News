import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ข่าวไทย RSS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          shadowColor: Colors.black26,
        ),
        cardTheme: CardThemeData(
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3),
            insets: EdgeInsets.symmetric(horizontal: 24),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          shadowColor: Colors.black54,
        ),
        cardTheme: CardThemeData(
          elevation: 6,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const NewsHomeScreen(),
    );
  }
}

class NewsHomeScreen extends StatelessWidget {
  const NewsHomeScreen({super.key});

  final List<Map<String, String>> tabs = const [
    {
      'title': 'ข่าวทั่วไป',
      'icon': 'home',
      'url': 'https://www.nationthailand.com/rss'
    },
    {
      'title': 'เศรษฐกิจ',
      'icon': 'business',
      'url': 'https://www.thailand.go.th/rss'
    },
    {
      'title': 'กีฬา',
      'icon': 'sports',
      'url': 'https://www.thairath.co.th/rss/sport'
    },
    {
      'title': 'เทคโนโลยี',
      'icon': 'tech',
      'url': 'https://world.thaipbs.or.th/rss'
    },
  ];

  IconData getTabIcon(String iconType) {
    switch (iconType) {
      case 'home':
        return Icons.home_rounded;
      case 'business':
        return Icons.business_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'tech':
        return Icons.computer_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.rss_feed_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ข่าวไทย RSS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            tabs: tabs
                .map((tab) => Tab(
                      icon: Icon(getTabIcon(tab['icon']!), size: 20),
                      text: tab['title'],
                      height: 60,
                    ))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: tabs
              .map((tab) => NewsTab(
                    rssUrl: tab['url']!,
                    categoryTitle: tab['title']!,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class NewsTab extends StatefulWidget {
  final String rssUrl;
  final String categoryTitle;
  const NewsTab({super.key, required this.rssUrl, required this.categoryTitle});

  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> with AutomaticKeepAliveClientMixin {
  List<RssItem> items = [];
  bool isLoading = true;
  String errorMessage = '';
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchRss();
  }

  Future<void> fetchRss() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // รายการ RSS URLs สำรอง
    final List<String> fallbackUrls = [
      widget.rssUrl,
      // URLs สำรองตามหมวดหมู่
      if (widget.categoryTitle == 'ข่าวทั่วไป') ...[
        'https://www.thairath.co.th/rss/news',
        'https://www.matichon.co.th/rss/news',
        'https://www.dailynews.co.th/rss/news.xml',
      ],
      if (widget.categoryTitle == 'เศรษฐกิจ') ...[
        'https://www.bangkokbiznews.com/rss/bangkokbiznews.xml',
        'https://www.prachachat.net/feed',
      ],
      if (widget.categoryTitle == 'กีฬา') ...[
        'https://www.siamsport.co.th/rss/news.xml',
        'https://www.thairath.co.th/rss/sport.xml',
      ],
      if (widget.categoryTitle == 'เทคโนโลยี') ...[
        'https://www.techtalkthai.com/feed/',
        'https://siamblockchain.com/feed/',
      ],
    ];

    for (String url in fallbackUrls) {
      try {
        debugPrint('กำลังลอง URL: $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'Mozilla/5.0 (compatible; RSS Reader App)',
            'Accept': 'application/rss+xml, application/xml, text/xml, */*',
            'Accept-Language': 'th,en;q=0.9',
          },
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('การเชื่อมต่อหมดเวลา');
          },
        );

        if (response.statusCode == 200) {
          try {
            final rssFeed = RssFeed.parse(response.body);
            if (rssFeed.items != null && rssFeed.items!.isNotEmpty) {
              setState(() {
                items = rssFeed.items!;
                isLoading = false;
              });
              debugPrint('โหลดสำเร็จจาก: $url');
              return; // สำเร็จแล้ว ออกจาก loop
            }
          } catch (parseError) {
            debugPrint('Parse error สำหรับ $url: $parseError');
            continue; // ลอง URL ถัดไป
          }
        } else {
          debugPrint('HTTP ${response.statusCode} สำหรับ $url');
          continue; // ลอง URL ถัดไป
        }
      } catch (e) {
        debugPrint('Error สำหรับ $url: $e');
        continue; // ลอง URL ถัดไป
      }
    }

    // ถ้าลองทุก URL แล้วไม่สำเร็จ
    setState(() {
      errorMessage = 'ไม่สามารถโหลดข่าว${widget.categoryTitle}ได้\nลองทุก RSS feed แล้ว';
      isLoading = false;
    });
  }

  void _onRefresh() async {
    await fetchRss();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'กำลังโหลดข่าว${widget.categoryTitle}...',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: fetchRss,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('ลองใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      header: WaterDropMaterialHeader(
        backgroundColor: Theme.of(context).colorScheme.primary,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: items.isEmpty 
        ? Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่มีข่าวสารในขณะนี้',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final imageUrl = extractImageUrl(item.description ?? '');
              final description = extractText(item.description ?? '');

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (item.link != null) launchUrlCustom(item.link!);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 220,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceVariant,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    height: 220,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceVariant,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.broken_image_rounded,
                                            size: 48,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'ไม่สามารถโหลดรูปภาพได้',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.categoryTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title ?? 'ไม่มีหัวข้อ',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      formatPubDate(item.pubDate ?? ''),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void launchUrlCustom(String url) async {
    try {
      final uri = Uri.parse(url);
      
      // ลองใช้ external application ก่อน
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      // ถ้าไม่ได้ ลองใช้ in-app browser
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppBrowserView,
        );
      }
      
      // ถ้ายังไม่ได้ ลองใช้ platform default
      if (!launched) {
        launched = await launchUrl(uri);
      }
      
      if (!launched) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Could not launch $url: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('ไม่สามารถเปิดลิงก์ได้: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'ตกลง',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  String? extractImageUrl(String html) {
    // ลองหา img tag แบบต่างๆ
    final imgPattern1 = RegExp(r'<img[^>]+src="([^">]+)"', caseSensitive: false);
    final imgPattern2 = RegExp(r"<img[^>]+src='([^'>]+)'", caseSensitive: false);
    final urlPattern = RegExp(r'https?://[^\s<>"]+\.(?:jpg|jpeg|png|gif|webp)', caseSensitive: false);
    
    // ลอง pattern แรก
    RegExpMatch? match = imgPattern1.firstMatch(html);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    
    // ลอง pattern ที่สอง
    match = imgPattern2.firstMatch(html);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    
    // ลอง pattern URL โดยตรง
    match = urlPattern.firstMatch(html);
    if (match != null) {
      return match.group(0);
    }
    
    return null;
  }

  String extractText(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  String formatPubDate(String pubDate) {
    try {
      DateTime date;
      
      // ลองแปลงรูปแบบวันที่ต่างๆ
      if (pubDate.contains('GMT') || pubDate.contains('+')) {
        date = DateTime.parse(pubDate.replaceAll(RegExp(r'\s\+\d{4}|\sGMT.*$'), ''));
      } else {
        date = DateTime.parse(pubDate);
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} วันที่แล้ว';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ชั่วโมงที่แล้ว';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} นาทีที่แล้ว';
      } else {
        return 'เพิ่งเผยแพร่';
      }
    } catch (e) {
      return pubDate.length > 20 ? pubDate.substring(0, 20) : pubDate;
    }
  }
}