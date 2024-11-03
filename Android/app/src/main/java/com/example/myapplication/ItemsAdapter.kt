package com.example.myapplication

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

data class Item(
    val nameBooks: String, // Имя книги
    val imageResId: Bitmap?, // Миниатюра книги
    val uri: Uri // URI файла книги
)

class ItemsAdapter(private val items: List<Item>, private val context: Context) : RecyclerView.Adapter<ItemsAdapter.MyViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.items_in_list, parent, false)
        return MyViewHolder(view)
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val item = items[position]
        holder.nameBook.text = item.nameBooks

        // Устанавливаем битмап в ImageView (если доступен)
        if (item.imageResId != null) {
            holder.image.setImageBitmap(item.imageResId)
        } else {
            println("pass")
        }

        // Устанавливаем обработчик клика на элемент
        holder.itemView.setOnClickListener {
            // При нажатии на книгу открываем новое активити с текстом книги
            val intent = Intent(context, BookTextActivity::class.java).apply {
                putExtra("BOOK_TEXT", item.uri.toString()) // Передаем текст книги
            }
            context.startActivity(intent)
        }
    }

    override fun getItemCount(): Int {
        return items.size
    }

    class MyViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val image: ImageView = view.findViewById(R.id.imageBook)
        val nameBook: TextView = view.findViewById(R.id.nameBook)
    }
}