# Panduan Praktik Spring AI — Chapter 1: Getting Started with Spring AI

Panduan ini membantu membangun aplikasi **Board Game Buddy** mengikuti alur Chapter 1 buku *Spring AI in Action*. Aplikasi menerima pertanyaan melalui REST API, meneruskan pertanyaan ke model OpenAI melalui Spring AI, lalu mengembalikan jawaban dalam format JSON.

> **Acuan versi dari buku:** Gradle Groovy DSL, Spring Boot `3.5.5`, Java `24`, dan Spring AI `1.0.1`. Chapter 1 juga menyebut Java 17 atau lebih baru dapat digunakan. Untuk mengikuti contoh sedekat mungkin, panduan ini memakai Java 24.
>
> **Keamanan:** jangan menaruh API key asli di source code, file `application.properties`, screenshot, atau repository Git. Panduan ini menggunakan environment variable.

---

## Daftar isi

1. [Hasil akhir yang akan dibuat](#1-hasil-akhir-yang-akan-dibuat)
2. [Persiapan software](#2-persiapan-software)
3. [Membuat project melalui Spring Initializr](#3-membuat-project-melalui-spring-initializr)
4. [Membuka project dan memeriksa struktur folder](#4-membuka-project-dan-memeriksa-struktur-folder)
5. [Mengatur Gradle dan dependency](#5-mengatur-gradle-dan-dependency)
6. [Membuat class Java](#6-membuat-class-java)
7. [Mengatur OpenAI API key](#7-mengatur-openai-api-key)
8. [Menambahkan pengujian WireMock](#8-menambahkan-pengujian-wiremock)
9. [Menjalankan pengujian](#9-menjalankan-pengujian)
10. [Menjalankan aplikasi](#10-menjalankan-aplikasi)
11. [Menguji REST API `/ask`](#11-menguji-rest-api-ask)
12. [Memilih model OpenAI lain](#12-memilih-model-openai-lain)
13. [Alternatif provider: Azure OpenAI](#13-alternatif-provider-azure-openai)
14. [Alternatif provider: Ollama](#14-alternatif-provider-ollama)
15. [Checklist screenshot untuk laporan](#15-checklist-screenshot-untuk-laporan)
16. [Troubleshooting singkat](#16-troubleshooting-singkat)
17. [Ringkasan alur aplikasi](#17-ringkasan-alur-aplikasi)

---

## 1. Hasil akhir yang akan dibuat

Setelah mengikuti langkah utama, project akan memiliki struktur seperti berikut:

```text
board-game-buddy/
├── build.gradle
├── settings.gradle
├── gradlew                  # launcher otomatis untuk macOS/Linux
├── gradlew.bat              # launcher otomatis untuk Windows
└── src/
    ├── main/
    │   ├── java/
    │   │   └── com/example/boardgamebuddy/
    │   │       ├── BoardGameBuddyApplication.java
    │   │       ├── BoardGameService.java
    │   │       ├── Question.java
    │   │       ├── Answer.java
    │   │       ├── SpringAiBoardGameService.java
    │   │       └── AskController.java
    │   └── resources/
    │       └── application.properties
    └── test/
        ├── java/
        │   └── com/example/boardgamebuddy/
        │       └── SpringAiBoardGameServiceWireMockTests.java
        └── resources/
            └── test-openai-response.json
```

Aplikasi menyediakan endpoint:

```text
POST http://localhost:8080/ask
```

Contoh request:

```json
{
  "question": "Why is the sky blue?"
}
```

Bentuk response:

```json
{
  "answer": "...jawaban yang dihasilkan model..."
}
```

Isi jawaban dapat berbeda setiap kali request dikirim karena respons model generatif tidak selalu sama.

---

## 2. Persiapan software

Pastikan software berikut sudah tersedia:

- **JDK 24** untuk mengikuti toolchain yang dipakai contoh buku.
- **IDE Java**, misalnya IntelliJ IDEA, Eclipse, atau Visual Studio Code dengan dukungan Java.
- **Gradle tidak perlu dipasang secara global.** Project menyertakan `gradlew` dan `gradlew.bat` yang mengunduh Gradle 8.14.8 pada pemakaian pertama dan memverifikasi SHA-256 distribusinya. Unduhan pertama memerlukan koneksi internet.
- **Akun dan API key OpenAI** untuk menjalankan request sungguhan ke OpenAI.
- **HTTP client** untuk menguji REST API, misalnya `curl`, HTTPie, atau Postman.

Periksa versi Java melalui terminal:

```bash
java -version
```

Pastikan Java yang aktif sesuai dengan versi yang akan digunakan. Jika memakai IDE, periksa juga Project SDK/JDK yang dipilih IDE.

**Screenshot yang disarankan**

- Ambil screenshot terminal yang menampilkan hasil `java -version`.
- Pastikan versi Java terlihat, tetapi jangan tampilkan informasi sensitif lain.
- Nama file: `01-java-version.png`.

---

## 3. Membuat project melalui Spring Initializr

Chapter 1 menggunakan Spring Initializr di [https://start.spring.io](https://start.spring.io). Buka situs tersebut, lalu isi pengaturan berikut.

| Bagian | Pilihan |
|---|---|
| Project | Gradle - Groovy |
| Language | Java |
| Spring Boot | `3.5.5` |
| Group | `com.example` |
| Artifact | `board-game-buddy` |
| Name | `board-game-buddy` |
| Package name | `com.example.boardgamebuddy` |
| Packaging | Jar |
| Java | `24` |
| Dependency 1 | Spring Web |
| Dependency 2 | Spring AI OpenAI |

Jika nama project atau metadata berbeda, package di kode Java harus disesuaikan agar konsisten.

Klik **Generate** untuk mengunduh file ZIP project. Ekstrak ZIP tersebut ke folder kerja.

**Screenshot yang disarankan**

- Screenshot halaman Spring Initializr sebelum menekan Generate.
- Pastikan pilihan Gradle Groovy, Java, Spring Boot 3.5.5, Java 24, Group/Artifact, dan dua dependency terlihat.
- Nama file: `02-spring-initializr-settings.png`.

---

## 4. Membuka project dan memeriksa struktur folder

Buka folder project hasil ekstraksi dari IDE. Pilih folder root project, yaitu folder yang berisi `build.gradle` dan `settings.gradle`, bukan hanya folder `src`.

Pastikan package Java berada di:

```text
src/main/java/com/example/boardgamebuddy/
```

File konfigurasi aplikasi berada di:

```text
src/main/resources/application.properties
```

Folder untuk pengujian berada di:

```text
src/test/java/com/example/boardgamebuddy/
```

Jika IDE menampilkan pertanyaan untuk mengimpor atau mempercayai project Gradle, pilih opsi untuk mengimpor/membuka sebagai project Gradle.

**Screenshot yang disarankan**

- Screenshot panel Project/Explorer pada IDE.
- Tampilkan root project, `build.gradle`, folder `src/main/java`, `src/main/resources`, dan `src/test`.
- Nama file: `03-project-structure.png`.

---

## 5. Mengatur Gradle dan dependency

Buka file `build.gradle` pada root project. Ganti atau sesuaikan isinya menjadi seperti berikut:

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.5.5'
    id 'io.spring.dependency-management' version '1.1.7'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(24)
    }
}

repositories {
    mavenCentral()
}

ext {
    set('springAiVersion', "1.0.1")
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.ai:spring-ai-starter-model-openai'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.wiremock.integrations:wiremock-spring-boot:3.9.0'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}

dependencyManagement {
    imports {
        mavenBom "org.springframework.ai:spring-ai-bom:${springAiVersion}"
    }
}

tasks.named('test') {
    useJUnitPlatform()
}
```

**Mengapa ada dependency WireMock?**

Di Chapter 1, dependency WireMock ditambahkan ketika pembahasan pengujian dimulai. Di panduan ini dependency tersebut sudah dimasukkan ke `build.gradle` agar file Gradle akhir siap menjalankan test yang dibuat pada Langkah 8.

Buka `settings.gradle` dan pastikan nama project terisi, misalnya:

```groovy
rootProject.name = 'board-game-buddy'
```

Simpan file. Pada IntelliJ IDEA pilih **Load Gradle Changes** atau **Reload All Gradle Projects**. Pada IDE lain, lakukan refresh/sync Gradle.

Tunggu sampai dependency selesai diunduh dan proses sinkronisasi tidak menampilkan error.

**Screenshot yang disarankan**

- Screenshot `build.gradle` yang memperlihatkan plugin, versi Spring AI, dan dependency utama.
- Jika memungkinkan, ambil satu screenshot tambahan yang memperlihatkan Gradle Sync selesai tanpa error.
- Nama file: `04-build-gradle.png` dan `05-gradle-sync.png`.

---

## 6. Membuat class Java

Semua class berikut menggunakan package:

```java
package com.example.boardgamebuddy;
```

Buat setiap file pada folder `src/main/java/com/example/boardgamebuddy/`.

### 6.1 `BoardGameService.java`

File ini mendefinisikan kontrak service untuk menerima pertanyaan dan menghasilkan jawaban.

```java
package com.example.boardgamebuddy;

public interface BoardGameService {
    Answer askQuestion(Question question);
}
```

### 6.2 `Question.java`

Record ini menyimpan pertanyaan yang dikirimkan oleh pengguna.

```java
package com.example.boardgamebuddy;

public record Question(String question) {
}
```

### 6.3 `Answer.java`

Record ini menyimpan jawaban yang dihasilkan oleh model.

```java
package com.example.boardgamebuddy;

public record Answer(String answer) {
}
```

### 6.4 `SpringAiBoardGameService.java`

Class ini mengimplementasikan `BoardGameService`. `ChatClient.Builder` diinjeksi melalui constructor lalu digunakan untuk membuat `ChatClient`. Method `askQuestion()` mengirim teks pertanyaan ke model dan membungkus hasilnya ke dalam `Answer`.

```java
package com.example.boardgamebuddy;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.stereotype.Service;

@Service
public class SpringAiBoardGameService implements BoardGameService {

    private final ChatClient chatClient;

    public SpringAiBoardGameService(ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder.build();
    }

    @Override
    public Answer askQuestion(Question question) {
        var answerText = chatClient.prompt()
                .user(question.question())
                .call()
                .content();
        return new Answer(answerText);
    }
}
```

Urutan pemanggilan `ChatClient`:

1. `prompt()` memulai penyusunan prompt.
2. `user(...)` memasukkan pertanyaan pengguna.
3. `call()` mengirim prompt ke model.
4. `content()` mengambil konten jawaban sebagai `String`.

### 6.5 `AskController.java`

Controller ini mengekspos endpoint `POST /ask`. Request JSON akan dipetakan ke record `Question`, kemudian diteruskan ke `BoardGameService`.

```java
package com.example.boardgamebuddy;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AskController {

    private final BoardGameService boardGameService;

    public AskController(BoardGameService boardGameService) {
        this.boardGameService = boardGameService;
    }

    @PostMapping(path = "/ask", produces = "application/json")
    public Answer ask(@RequestBody Question question) {
        return boardGameService.askQuestion(question);
    }
}
```

### 6.6 `BoardGameBuddyApplication.java`

Class ini adalah entry point standar Spring Boot. Spring Initializr biasanya membuatnya otomatis. Pastikan class ini ada di package yang sama agar component scanning dapat menemukan controller dan service.

```java
package com.example.boardgamebuddy;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BoardGameBuddyApplication {

    public static void main(String[] args) {
        SpringApplication.run(BoardGameBuddyApplication.class, args);
    }
}
```

**Screenshot yang disarankan**

- Ambil screenshot package `com.example.boardgamebuddy` yang menampilkan semua file Java.
- Ambil screenshot kedua yang memperlihatkan isi `SpringAiBoardGameService.java`.
- Ambil screenshot ketiga yang memperlihatkan `AskController.java` dan mapping `POST /ask`.
- Pastikan nama file dan deklarasi package terbaca.
- Nama file: `06-java-classes.png`, `07-service-class.png`, dan `08-ask-controller.png`.

---

## 7. Mengatur OpenAI API key

Aplikasi perlu API key agar dapat mengirim request ke OpenAI. Chapter 1 menyebut properti `spring.ai.openai.api-key`, dan menyarankan penggunaan environment variable agar secret tidak ikut masuk ke source control.

### 7.1 Isi `application.properties`

Buat atau buka file:

```text
src/main/resources/application.properties
```

Isi dengan:

```properties
spring.ai.openai.api-key=${SPRING_AI_OPENAI_API_KEY}
```

### 7.2 Mengatur environment variable

Gunakan perintah sesuai sistem operasi dan terminal yang digunakan.

**Windows PowerShell:**

```powershell
$env:SPRING_AI_OPENAI_API_KEY = "ISI_DENGAN_API_KEY_MILIK_SENDIRI"
```

**Windows Command Prompt (CMD):**

```bat
set SPRING_AI_OPENAI_API_KEY=ISI_DENGAN_API_KEY_MILIK_SENDIRI
```

**macOS / Linux:**

```bash
export SPRING_AI_OPENAI_API_KEY="ISI_DENGAN_API_KEY_MILIK_SENDIRI"
```

Jalankan perintah tersebut pada terminal yang sama dengan terminal yang akan digunakan untuk menjalankan aplikasi. Ganti nilai contoh dengan API key milik sendiri. Jangan menuliskan API key pada dokumen laporan.

> **Penting untuk screenshot:** jangan pernah mengambil screenshot yang memperlihatkan API key secara utuh. Tutupi atau samarkan nilainya. Screenshot yang paling aman adalah menampilkan `application.properties` dengan placeholder `${SPRING_AI_OPENAI_API_KEY}`.

**Screenshot yang disarankan**

- Screenshot `application.properties` yang memperlihatkan konfigurasi placeholder environment variable.
- Jangan tampilkan secret/key pada terminal atau IDE.
- Nama file: `09-openai-properties.png`.

---

## 8. Menambahkan pengujian WireMock

Chapter 1 menggunakan WireMock untuk menggantikan endpoint OpenAI dengan mock response yang sudah diketahui. Dengan demikian, pengujian service tidak perlu mengirim request sungguhan ke OpenAI.

Pastikan dependency WireMock sudah ada di blok `dependencies` `build.gradle`:

```groovy
testImplementation 'org.wiremock.integrations:wiremock-spring-boot:3.9.0'
```

### 8.1 Membuat file response JSON

Buat folder dan file berikut:

```text
src/test/resources/test-openai-response.json
```

Isi file:

```json
{
  "id": "chatcmpl-example",
  "object": "chat.completion",
  "created": 1745182545,
  "model": "gpt-4.5-preview-2025-02-27",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Paris",
        "refusal": null,
        "annotations": []
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 11,
    "completion_tokens": 13,
    "total_tokens": 24,
    "prompt_tokens_details": {
      "cached_tokens": 0,
      "audio_tokens": 0
    },
    "completion_tokens_details": {
      "reasoning_tokens": 0,
      "audio_tokens": 0,
      "accepted_prediction_tokens": 0,
      "rejected_prediction_tokens": 0
    }
  },
  "service_tier": "default",
  "system_fingerprint": null
}
```

Untuk pengujian ini, nilai pentingnya adalah `choices[0].message.content` yang berisi `Paris`.

### 8.2 Membuat test class

Buat file:

```text
src/test/java/com/example/boardgamebuddy/SpringAiBoardGameServiceWireMockTests.java
```

Isi file:

```java
package com.example.boardgamebuddy;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.tomakehurst.wiremock.client.ResponseDefinitionBuilder;
import com.github.tomakehurst.wiremock.client.WireMock;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.Resource;
import org.wiremock.spring.ConfigureWireMock;
import org.wiremock.spring.EnableWireMock;

import java.io.IOException;
import java.nio.charset.Charset;

@EnableWireMock(
        @ConfigureWireMock(baseUrlProperties = "openai.base.url"))
@SpringBootTest(
        properties = "spring.ai.openai.base-url=${openai.base.url}")
public class SpringAiBoardGameServiceWireMockTests {

    @Value("classpath:/test-openai-response.json")
    Resource responseResource;

    @Autowired
    ChatClient.Builder chatClientBuilder;

    @BeforeEach
    public void setup() throws IOException {
        var cannedResponse =
                responseResource.getContentAsString(Charset.defaultCharset());
        var mapper = new ObjectMapper();
        var responseNode = mapper.readTree(cannedResponse);
        WireMock.stubFor(WireMock.post("/v1/chat/completions")
                .willReturn(ResponseDefinitionBuilder.okForJson(responseNode)));
    }

    @Test
    public void testAskQuestion() {
        var boardGameService =
                new SpringAiBoardGameService(chatClientBuilder);
        var answer = boardGameService.askQuestion(
                new Question("What is the capital of France?"));

        Assertions.assertThat(answer).isNotNull();
        Assertions.assertThat(answer.answer()).isEqualTo("Paris");
    }
}
```

Test tersebut mengatur mock untuk request `POST /v1/chat/completions`, lalu memastikan service menghasilkan jawaban `Paris`.

**Screenshot yang disarankan**

- Screenshot isi `SpringAiBoardGameServiceWireMockTests.java` yang memperlihatkan konfigurasi WireMock dan assertion `isEqualTo("Paris")`.
- Screenshot file `test-openai-response.json` yang memperlihatkan response mock berisi `Paris`.
- Nama file: `10-wiremock-test-code.png` dan `11-wiremock-response-json.png`.

---

## 9. Menjalankan pengujian

Jalankan test dari terminal pada root project.

**macOS / Linux:**

```bash
./gradlew test
```

**Windows:**

```bat
.\gradlew.bat test
```

Test WireMock menggunakan response mock `Paris`, bukan jawaban live dari OpenAI. Karena itu test ini dirancang agar tidak memerlukan API key OpenAI yang valid.

Hasil yang diharapkan adalah task test selesai dengan status `BUILD SUCCESSFUL` dan test tidak gagal.

**Screenshot yang disarankan**

- Screenshot terminal setelah perintah test selesai.
- Pastikan terlihat `BUILD SUCCESSFUL` atau indikator test berhasil pada IDE.
- Jika IDE menampilkan jumlah test, pastikan statusnya hijau/pass.
- Nama file: `12-wiremock-test-passed.png`.

---

## 10. Menjalankan aplikasi

Untuk menjalankan aplikasi Spring Boot:

**macOS / Linux:**

```bash
./gradlew bootRun
```

**Windows:**

```bat
.\gradlew.bat bootRun
```

Pastikan environment variable `SPRING_AI_OPENAI_API_KEY` sudah diatur pada terminal yang sama. Tunggu sampai Spring Boot selesai melakukan startup. Secara default server berjalan pada port `8080`.

Biarkan terminal proses aplikasi tetap berjalan ketika menguji endpoint.

**Screenshot yang disarankan**

- Screenshot terminal saat aplikasi berhasil startup.
- Pastikan terlihat pesan bahwa aplikasi telah berjalan, serta tidak ada error startup.
- Jangan tampilkan environment variable yang berisi API key.
- Nama file: `13-application-started.png`.

---

## 11. Menguji REST API `/ask`

Chapter 1 menunjukkan pengujian endpoint menggunakan `curl` atau HTTPie. Kamu dapat memakai salah satu atau Postman.

### 11.1 Menggunakan curl

Jalankan pada terminal baru (jangan menghentikan terminal aplikasi):

```bash
curl localhost:8080/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"Why is the sky blue?"}'
```

### 11.2 Menggunakan HTTPie

```bash
http :8080/ask question="Why is the sky blue?" -b
```

### 11.3 Menggunakan Postman

Jika menggunakan Postman, atur:

| Pengaturan | Nilai |
|---|---|
| Method | `POST` |
| URL | `http://localhost:8080/ask` |
| Header | `Content-Type: application/json` |
| Body | raw → JSON |

Isi body:

```json
{
  "question": "Why is the sky blue?"
}
```

Tekan **Send**. Jika konfigurasi benar dan API key valid, response JSON akan berisi properti `answer`.

Contoh struktur response:

```json
{
  "answer": "The sky appears blue because ..."
}
```

Teks jawaban di atas hanya contoh bentuk response. Isi jawaban sebenarnya dapat berubah antar-request.

**Screenshot yang disarankan**

- Jika memakai Postman: screenshot yang menampilkan method `POST`, URL `/ask`, request body JSON, status response, dan response JSON.
- Jika memakai terminal: screenshot command `curl`/HTTPie dan response JSON.
- Pastikan tidak ada API key atau secret di screenshot.
- Nama file: `14-postman-request.png` atau `14-curl-request-response.png`.

---

## 12. Memilih model OpenAI lain

Bagian ini **opsional**. Chapter 1 menyebut Spring AI menggunakan model default OpenAI dan menunjukkan cara mengganti model melalui properti.

Untuk contoh pada buku, tambahkan properti berikut di `application.properties`:

```properties
spring.ai.openai.chat.options.model=gpt-4.1-nano
```

Contoh ini mengganti model default menjadi `gpt-4.1-nano`. Model yang tersedia dapat berubah dari waktu ke waktu. Pastikan model yang dipilih masih tersedia dan dapat digunakan oleh akun OpenAI kamu.

Chapter 1 juga menunjukkan cara memeriksa daftar model dengan HTTPie:

```bash
http -A bearer -a "$SPRING_AI_OPENAI_API_KEY" https://api.openai.com/v1/models
```

Jangan mengambil screenshot yang memperlihatkan API key atau kredensial yang dimasukkan pada command line. Untuk dokumentasi, lebih aman screenshot properti model yang sudah disamarkan atau output daftar model setelah memastikan tidak ada secret di layar.

**Screenshot opsional**

- Screenshot `application.properties` yang memperlihatkan properti pemilihan model.
- Nama file: `15-openai-model-selection.png`.

---

## 13. Alternatif provider: Azure OpenAI

Bagian ini adalah **alternatif**, bukan dependency yang perlu ditambahkan bersamaan dengan OpenAI biasa. Jika memilih Azure OpenAI, gunakan starter Azure OpenAI:

```groovy
implementation 'org.springframework.ai:spring-ai-starter-model-azure-openai'
```

Contoh konfigurasi:

```properties
spring.ai.azure.openai.api-key=${SPRING_AI_AZURE_OPENAI_API_KEY}
spring.ai.azure.openai.chat.options.deployment-name=gpt-4
```

Atur API key Azure sebagai environment variable.

**Windows PowerShell:**

```powershell
$env:SPRING_AI_AZURE_OPENAI_API_KEY = "ISI_DENGAN_AZURE_API_KEY"
```

**macOS / Linux:**

```bash
export SPRING_AI_AZURE_OPENAI_API_KEY="ISI_DENGAN_AZURE_API_KEY"
```

Chapter 1 menegaskan bahwa OpenAI dan Azure OpenAI merupakan provider terpisah; API key OpenAI biasa tidak menggantikan API key Azure OpenAI.

**Screenshot opsional**

- Ambil hanya jika project memang dikonfigurasi menggunakan Azure OpenAI.
- Tampilkan dependency dan properti deployment name tanpa menampilkan secret.
- Nama file: `16-azure-openai-config.png`.

---

## 14. Alternatif provider: Ollama

Ollama menjadi opsi untuk menjalankan model lokal. Bagian ini juga **alternatif**, bukan konfigurasi yang wajib untuk project OpenAI.

### 14.1 Mengunduh model

Chapter 1 memberikan contoh perintah:

```bash
ollama pull gemma:2b
```

atau:

```bash
ollama pull mistral:7b
```

Periksa model yang sudah tersedia:

```bash
ollama list
```

Chapter 1 juga menunjukkan endpoint tag Ollama menggunakan HTTPie:

```bash
http http://localhost:11434/api/tags -b
```

### 14.2 Mengganti dependency

Gunakan starter Ollama:

```groovy
implementation 'org.springframework.ai:spring-ai-starter-model-ollama'
```

### 14.3 Mengatur properti

Contoh konfigurasi model:

```properties
spring.ai.ollama.chat.model=gemma:2b
spring.ai.ollama.init.pull-model-strategy=when_missing
```

Chapter 1 menjelaskan pilihan strategi `when_missing`, `always`, dan `never` (nilai default yang dijelaskan buku). Pengambilan model otomatis bisa menambah waktu startup aplikasi.

**Screenshot opsional**

- Screenshot terminal `ollama list` yang memperlihatkan model sudah tersedia.
- Screenshot `application.properties` yang memperlihatkan model Ollama yang dipilih.
- Jangan gabungkan screenshot konfigurasi provider alternatif ke bukti project OpenAI jika kamu tidak benar-benar menggunakan Ollama.
- Nama file: `17-ollama-model-list.png` dan `18-ollama-config.png`.

---

## 15. Checklist screenshot untuk laporan

Untuk laporan praktik Chapter 1, screenshot berikut sudah cukup untuk membuktikan alur pengerjaan utama. Tidak semua screenshot opsional harus dibuat.

| No. | Nama file yang disarankan | Bagian yang harus terlihat | Wajib? |
|---:|---|---|---|
| 1 | `01-java-version.png` | Hasil `java -version` | Disarankan |
| 2 | `02-spring-initializr-settings.png` | Pengaturan project dan dependency di Spring Initializr | Ya |
| 3 | `03-project-structure.png` | Struktur folder project pada IDE | Ya |
| 4 | `04-build-gradle.png` | Plugin, versi, dan dependency di `build.gradle` | Ya |
| 5 | `05-gradle-sync.png` | Gradle Sync/Reload selesai tanpa error | Disarankan |
| 6 | `06-java-classes.png` | Package dan daftar class Java | Ya |
| 7 | `07-service-class.png` | Implementasi `SpringAiBoardGameService` | Disarankan |
| 8 | `08-ask-controller.png` | Controller dan endpoint `POST /ask` | Ya |
| 9 | `09-openai-properties.png` | Placeholder API key pada `application.properties` | Ya |
| 10 | `10-wiremock-test-code.png` | Kode test dan assertion `Paris` | Ya |
| 11 | `11-wiremock-response-json.png` | Mock response JSON dengan content `Paris` | Disarankan |
| 12 | `12-wiremock-test-passed.png` | Hasil test berhasil | Ya |
| 13 | `13-application-started.png` | Aplikasi berhasil dijalankan | Ya |
| 14 | `14-postman-request.png` atau `14-curl-request-response.png` | Request POST dan response JSON | Ya |
| 15 | `15-openai-model-selection.png` | Properti model OpenAI tambahan | Opsional |
| 16 | `16-azure-openai-config.png` | Konfigurasi Azure OpenAI | Opsional, hanya bila dipakai |
| 17 | `17-ollama-model-list.png` | Daftar model lokal Ollama | Opsional, hanya bila dipakai |
| 18 | `18-ollama-config.png` | Konfigurasi model Ollama | Opsional, hanya bila dipakai |

### Tips mengambil screenshot

1. Gunakan screenshot asli dari IDE, terminal, Spring Initializr, atau Postman.
2. Pastikan teks penting dapat dibaca; perbesar editor atau terminal bila perlu.
3. Hindari mengambil screenshot seluruh desktop jika bagian yang relevan bisa dipotong dengan rapi.
4. Beri nama file sesuai tabel agar mudah dirujuk dalam laporan.
5. Jangan menampilkan API key, token, password, atau informasi akun.
6. Jangan mengedit isi output terminal atau response agar tampak berhasil. Jika ada error, perbaiki lebih dulu lalu ambil bukti ulang.
7. Letakkan semua screenshot pada folder `screenshots/` di samping file dokumentasi.

Contoh susunan folder dokumentasi:

```text
laporan-spring-ai-chapter1/
├── Panduan-Praktik-Spring-AI-Chapter-1.md
└── screenshots/
    ├── 01-java-version.png
    ├── 02-spring-initializr-settings.png
    ├── 03-project-structure.png
    └── ...
```

---

## 16. Troubleshooting singkat

| Gejala | Hal yang perlu diperiksa |
|---|---|
| Gradle gagal menemukan Java toolchain 24 | Periksa JDK yang terpasang dan konfigurasi Gradle/IDE. Pastikan JDK 24 tersedia jika memakai toolchain 24. |
| Dependency tidak terunduh | Periksa koneksi internet, konfigurasi proxy, dan lakukan Gradle Sync/Refresh lagi. |
| `SPRING_AI_OPENAI_API_KEY` tidak terbaca | Pastikan environment variable diatur di terminal atau run configuration yang benar. Restart proses aplikasi setelah mengubah nilainya. |
| OpenAI mengembalikan error autentikasi | Periksa validitas API key dan pastikan key milik OpenAI, bukan Azure OpenAI. Jangan menaruh key di screenshot. |
| Port 8080 sudah digunakan | Hentikan aplikasi lain yang menggunakan port tersebut atau ubah konfigurasi port aplikasi. |
| Test WireMock gagal | Periksa dependency WireMock, lokasi file JSON di `src/test/resources`, dan lokasi package/file test. |
| Endpoint `/ask` tidak ditemukan | Pastikan aplikasi sudah berjalan, URL benar, method adalah `POST`, dan `AskController` berada di package yang terjangkau `@SpringBootApplication`. |

---

## 17. Ringkasan alur aplikasi

Alur request pada project ini adalah:

```text
Client (Postman / curl / HTTPie)
            |
            | POST /ask
            | { "question": "..." }
            v
       AskController
            |
            v
      BoardGameService
            |
            v
 SpringAiBoardGameService
            |
            v
        ChatClient
            |
            v
       OpenAI Model
            |
            v
     Generated Answer
            |
            v
    Response JSON ke Client
```

File-file utama memiliki peran berikut:

| Komponen | Tanggung jawab |
|---|---|
| `Question` | Menyimpan pertanyaan dari request |
| `Answer` | Menyimpan jawaban model |
| `BoardGameService` | Kontrak service |
| `SpringAiBoardGameService` | Mengirim prompt menggunakan Spring AI `ChatClient` |
| `AskController` | Menyediakan REST endpoint `POST /ask` |
| `BoardGameBuddyApplication` | Menjalankan Spring Boot |
| `SpringAiBoardGameServiceWireMockTests` | Menguji service menggunakan mock response |

**Rujukan PDF:** *Spring AI in Action*, Chapter 1, terutama bagian 1.1.1–1.1.4 dan 1.2–1.2.2 (PDF halaman 8–28). Contoh build Gradle ada pada Listing 1.1; service pada Listing 1.2; controller pada Listing 1.3; dan test WireMock pada Listing 1.4.
