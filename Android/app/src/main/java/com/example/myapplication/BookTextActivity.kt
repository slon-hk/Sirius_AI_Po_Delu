package com.example.myapplication

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class BookTextActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_book_text)

        // Получаем текст книги из Intent
        val bookText = intent.getStringExtra("BOOK_TEXT")

        // Находим TextView и отображаем текст книги
        val textView: TextView = findViewById(R.id.bookTextView)
        textView.text = bookText
    }
}