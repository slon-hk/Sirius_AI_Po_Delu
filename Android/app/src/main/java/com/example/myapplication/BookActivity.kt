package com.example.myapplication

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import org.apache.pdfbox.pdmodel.PDDocument
import org.apache.pdfbox.text.PDFTextStripper

class BookActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var itemsAdapter: ItemsAdapter
    private lateinit var addFileBtn: Button
    private lateinit var headerText: TextView
    private val items = mutableListOf<Item>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_book)

        recyclerView = findViewById(R.id.booksList)
        addFileBtn = findViewById(R.id.addFileBtn)
        headerText = findViewById(R.id.headerText)

        // Установка GridLayoutManager с двумя колонками
        itemsAdapter = ItemsAdapter(items, this)
        val gridLayoutManager = GridLayoutManager(this, 2) // 2 колонки
        recyclerView.layoutManager = gridLayoutManager
        recyclerView.adapter = itemsAdapter

        // Установка обработчика нажатия кнопки
        addFileBtn.setOnClickListener {
            openFileChooser()
        }
    }

    private fun openFileChooser() {
        // Открытие меню выбора файла
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/pdf" // Фильтр только для PDF
        }
        fileChooserLauncher.launch(intent)
    }

    // Регистрация для получения результата выбора файла
    private val fileChooserLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (result.resultCode == Activity.RESULT_OK) {
                result.data?.let { data ->
                    data.data?.let { uri ->
                        addBook(uri)
                    }
                }
            }
        }

    private fun addBook(uri: Uri) {
        val fileName = getFileName(uri)
        val pdfThumbnail = getPdfThumbnail(uri) // Получаем миниатюру PDF

        // Извлекаем текст из PDF-файла
        val pdfText = extractPdfText(uri)

        // Создаем объект Item, передаем имя файла, миниатюру (Bitmap?) и URI
        val item = Item(fileName ?: "Unknown", pdfThumbnail, uri)
        items.add(item)
        itemsAdapter.notifyItemInserted(items.size - 1)

        // Обновляем видимость заголовка
        if (items.size == 1) {
            headerText.visibility = View.VISIBLE
            headerText.text = "Последние открытые книги"
        }

        // Открываем новое активити для отображения текста
        val intent = Intent(this, BookTextActivity::class.java).apply {
            putExtra("BOOK_TEXT", pdfText) // Передаем текст книги
        }
        startActivity(intent)
    }

    private fun extractPdfText(uri: Uri): String {
        val inputStream = contentResolver.openInputStream(uri)
        var pdfText = ""

        inputStream?.use {
            try {
                // Открываем PDF-файл с помощью PDFBox
                val document = PDDocument.load(it)
                val pdfStripper = PDFTextStripper()

                // Извлекаем текст из PDF
                pdfText = pdfStripper.getText(document)

                // Закрываем документ после извлечения текста
                document.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        return pdfText
    }

    private fun getFileName(uri: Uri): String? {
        var name: String? = null
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (cursor.moveToFirst()) {
                name = cursor.getString(nameIndex)
            }
        }
        return name
    }

    private fun getPdfThumbnail(uri: Uri): Bitmap? {
        try {
            // Открываем PDF файл через contentResolver
            val parcelFileDescriptor = contentResolver.openFileDescriptor(uri, "r")

            // Если не удается открыть файл, возвращаем null
            if (parcelFileDescriptor != null) {
                // Создаем PdfRenderer для работы с PDF-файлом
                val pdfRenderer = PdfRenderer(parcelFileDescriptor)

                // Открываем первую страницу PDF-файла (индекс страницы 0)
                val page = pdfRenderer.openPage(0)

                // Создаем Bitmap с размерами страницы
                val bitmap = Bitmap.createBitmap(page.width, page.height, Bitmap.Config.ARGB_8888)

                // Рендерим содержимое страницы в Bitmap
                page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)

                // Закрываем страницу и PdfRenderer
                page.close()
                pdfRenderer.close()

                // Закрываем ParcelFileDescriptor
                parcelFileDescriptor.close()

                // Возвращаем миниатюру (Bitmap)
                return bitmap
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // В случае ошибки или если не удалось открыть файл, возвращаем null
        return null
    }
}