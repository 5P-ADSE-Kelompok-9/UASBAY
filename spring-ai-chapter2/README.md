# Spring AI - Chapter 2

Project pendamping Chapter 2, **Evaluating Generated Responses**, dari buku *Spring AI in Action*.

## Isi project

- `RelevancyEvaluator` dan `FactCheckingEvaluator` pada integration test.
- `SelfEvaluatingBoardGameService` untuk mengevaluasi relevansi jawaban saat runtime.
- `AnswerNotRelevantException` sebagai pemicu retry.
- `@EnableRetry` untuk mengaktifkan pemrosesan `@Retryable`.
- Profile `self-evaluating` agar implementasi Chapter 1 dan Chapter 2 dapat dipilih tanpa membuat dua bean `BoardGameService` sekaligus.

## Prasyarat

- JDK 24 (mengikuti toolchain contoh buku).
- Gradle 8.14.8 disediakan otomatis melalui `gradlew.bat` (Windows) atau `gradlew` (macOS/Linux). Gradle tidak perlu dipasang global; unduhan pertama memerlukan internet.
- OpenAI API key dengan akses dan billing yang aktif untuk test evaluator dan pemanggilan runtime.

## API key

Windows PowerShell:

```powershell
$env:SPRING_AI_OPENAI_API_KEY="isi-api-key-kamu"
```

macOS / Linux:

```bash
export SPRING_AI_OPENAI_API_KEY="isi-api-key-kamu"
```

Jangan memasukkan API key ke Git atau membagikannya.

## Menjalankan test

Windows PowerShell menggunakan `.\gradlew.bat`; macOS/Linux menggunakan `./gradlew`.

Test evaluator mengirim permintaan sungguhan ke model OpenAI. Karena itu, test membutuhkan API key dan dapat menimbulkan biaya penggunaan.

```bash
./gradlew test --tests "com.example.boardgamebuddy.SpringAiBoardGameServiceTests"
```

Windows PowerShell:

```powershell
.\gradlew.bat test --tests "com.example.boardgamebuddy.SpringAiBoardGameServiceTests"
```

Test WireMock yang diwarisi dari Chapter 1 dapat dijalankan terpisah:

```bash
./gradlew test --tests "com.example.boardgamebuddy.SpringAiBoardGameServiceWireMockTests"
```

Windows PowerShell:

```powershell
.\gradlew.bat test --tests "com.example.boardgamebuddy.SpringAiBoardGameServiceWireMockTests"
```

## Menjalankan aplikasi

Di Windows PowerShell, ganti awalan `./gradlew` dengan `.\gradlew.bat`.

Mode dasar seperti Chapter 1:

```bash
./gradlew bootRun
```

Mode self-evaluation Chapter 2:

```bash
./gradlew bootRun --args='--spring.profiles.active=self-evaluating'
```

Endpoint:

```http
POST http://localhost:8080/ask
Content-Type: application/json
```

Body:

```json
{
  "question": "Why is the sky blue?"
}
```

## Catatan implementasi

Buku memperkenalkan `@Retryable` dan `@Recover` pada listing runtime. Project ini menambahkan `RetryConfiguration` dengan `@EnableRetry` agar mekanisme retry diaktifkan secara eksplisit. Implementasi service dasar menggunakan profile `!self-evaluating`, sementara service self-evaluating aktif pada profile `self-evaluating`.
