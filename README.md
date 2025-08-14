# JJB News App 📰

> โปรเจคงานที่2 ของการสร้างแอพพลิเคชั่น (Project 2: Application Development)

แอปพลิเคชันข่าวสารที่พัฒนาด้วย Flutter สำหรับการอ่านข่าวและติดตามข้อมูลข่าวสารต่างๆ

## 🚀 Features (คุณสมบัติ)

- 📱 รองรับทั้ง Android และ iOS
- 🔄 อัปเดตข่าวสารแบบ Real-time
- 🌐 รองรับหลายหมวดหมู่ข่าว
- 💾 บันทึกข่าวที่สนใจ
- 🔍 ค้นหาข่าวสาร
- 🎨 UI/UX ที่สวยงามและใช้งานง่าย

## 🛠 Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **Platform**: Cross-platform (Android & iOS)

## 📋 Prerequisites (ข้อกำหนดเบื้องต้น)

ก่อนเริ่มใช้งาน ต้องติดตั้งสิ่งเหล่านี้ในระบบ:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (เวอร์ชันล่าสุด)
- [Dart SDK](https://dart.dev/get-dart) (มาพร้อมกับ Flutter)
- [Android Studio](https://developer.android.com/studio) หรือ [VS Code](https://code.visualstudio.com/)
- Git

## 🔧 Installation (การติดตั้ง)

1. **Clone repository**
   ```bash
   git clone https://github.com/sompong47/JJB_News.git
   cd JJB_News
   ```

2. **ติดตั้ง dependencies**
   ```bash
   flutter pub get
   ```

3. **ตรวจสอบการตั้งค่า Flutter**
   ```bash
   flutter doctor
   ```

4. **รันแอปพลิเคชัน**
   ```bash
   # สำหรับ Android
   flutter run

   # สำหรับ iOS (macOS เท่านั้น)
   flutter run -d ios
   ```

## 📁 Project Structure (โครงสร้างโปรเจค)

```
JJB_News/
├── android/                 
├── ios/                 
├── lib/                   
│   ├── main.dart          
├── assets/                 
├── test/                
├── pubspec.yaml
└── README.md              
```

## 🔑 Dependencies (ไลบรารีที่ใช้)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5           # HTTP requests
  provider: ^6.0.5       # State management
  cached_network_image: ^3.2.3  # Image caching
  shared_preferences: ^2.0.15   # Local storage
  # Add other dependencies as needed
```

## 🖥 Screenshots (ภาพตัวอย่าง)

|
<img width="357" height="797" alt="สกรีนช็อต 2025-08-14 205054" src="https://github.com/user-attachmen<img width="358" height="770" alt="สกรีนช็อต 2025-08-14 205118" src="https://github.com/user-attachments/assets/6a4c0825-5b6b-4088-99bc-5ed6256febe4" />
ts/assets/07888a1e-2a91-492b-b283-f34736878ae3" />



## 🚀 Build & Deploy

### สำหรับ Android:
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### สำหรับ iOS:
```bash
# Build iOS app
flutter build ios --release
```

## 🧪 Testing (การทดสอบ)

รันการทดสอบด้วยคำสั่ง:
```bash
# Unit tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart
```

## 🤝 Contributing (การมีส่วนร่วม)

1. Fork โปรเจค
2. สร้าง feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit การเปลี่ยนแปลง (`git commit -m 'Add some AmazingFeature'`)
4. Push ไปยัง branch (`git push origin feature/AmazingFeature`)
5. เปิด Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Sompong47** - *Initial work* - [sompong47](https://github.com/sompong47)

## 🙏 Acknowledgments

- Flutter team สำหรับ framework ที่ยอดเยี่ยม
- ชุมชน Flutter สำหรับแพ็คเกจและตัวอย่างต่างๆ
- News API providers สำหรับข้อมูลข่าวสาร

## 📞 Support

หากพบปัญหาหรือมีข้อสงสัย สามารถ:
- เปิด [Issue](https://github.com/sompong47/JJB_News/issues) ใน GitHub
- ติดต่อผู้พัฒนาผ่าน GitHub

## 📈 Roadmap

- [ ] เพิ่มการแจ้งเตือนข่าวสาร
- [ ] รองรับโหมดมืด (Dark Mode)
- [ ] เพิ่มการแชร์ข่าวสาร
- [ ] รองรับหลายภาษา
- [ ] ปรับปรุง UI/UX

---

**Made with ❤️ using Flutter**
