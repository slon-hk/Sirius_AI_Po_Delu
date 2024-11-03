import logging
import aiohttp
import pdfplumber
from docx import Document
from ebooklib import epub
import chardet
from aiogram import Bot, Dispatcher, Router, types
from aiogram.filters import Command
from aiogram.types import ContentType
import asyncio
import os

# Telegram API токен и URL API-сервера
API_TOKEN = ""
API_SERVER_URL = ""

# Настройка логирования
logging.basicConfig(level=logging.INFO)

# Инициализация бота и диспетчера
bot = Bot(token=API_TOKEN)
dp = Dispatcher()
router = Router()


async def send_text_to_server(text):
    """Отправляет текст на API-сервер и получает краткое содержание."""
    async with aiohttp.ClientSession() as session:
        try:
            async with session.post(API_SERVER_URL, json={"text": text}) as response:
                if response.status == 200:
                    result = await response.json()
                    return result.get("summary", "Краткое содержание не найдено.")
                logging.error(f"Ошибка: статус {response.status} при запросе к API-серверу")
                return "Произошла ошибка на сервере. Попробуйте позже."
        except Exception as e:
            logging.error(f"Ошибка подключения к серверу: {e}")
            return "Не удалось подключиться к серверу."


def extract_text_from_pdf(file_path):
    """Извлекает текст из PDF файла."""
    with pdfplumber.open(file_path) as pdf:
        return ''.join(page.extract_text() or '' for page in pdf.pages)


def extract_text_from_docx(file_path):
    """Извлекает текст из DOCX файла."""
    doc = Document(file_path)
    return '\n'.join(paragraph.text for paragraph in doc.paragraphs)


def extract_text_from_txt(file_path):
    """Извлекает текст из TXT файла, определяя его кодировку."""
    with open(file_path, 'rb') as f:
        raw_data = f.read()
        encoding = chardet.detect(raw_data)['encoding']
    return raw_data.decode(encoding)


def extract_text_from_epub(file_path):
    """Извлекает текст из EPUB файла."""
    book = epub.read_epub(file_path)
    text = []
    for item in book.get_items():
        if item.get_type() == epub.EPUB_CONTENT_DOCUMENT:
            text.append(item.get_body_content().decode('utf-8'))
    return ''.join(text)


@router.message(Command("start"))
async def handle_start_command(message: types.Message):
    """Обрабатывает команду /start."""
    await message.answer(
        "Привет! Отправьте файл PDF, DOCX, TXT или EPUB для получения краткого содержания или отправьте текстовое сообщение."
    )


@router.message(Command("help"))
async def handle_help_command(message: types.Message):
    """Отправляет справочную информацию пользователю по команде /help."""
    help_text = (
        "Этот бот позволяет получить краткое содержание ваших документов.\n"
        "Поддерживаемые форматы файлов: PDF, DOCX, TXT, EPUB.\n"
        "Просто отправьте файл или текст, и я обработаю его для вас!\n"
        "Для получения краткого содержания отправьте команду /summary и прикрепите файл или текст."
    )
    await message.answer(help_text)


@router.message(Command("formats"))
async def handle_formats_command(message: types.Message):
    """Отправляет информацию о поддерживаемых форматах файлов по команде /formats."""
    formats_text = (
        "Поддерживаемые форматы файлов:\n"
        "- PDF\n"
        "- DOCX\n"
        "- TXT\n"
        "- EPUB\n"
        "Пожалуйста, отправьте файл одного из этих форматов или текст."
    )
    await message.answer(formats_text)


@router.message(types.Message.document)
async def handle_document_message(message: types.Message):
    """Обрабатывает сообщения с файлами от пользователя."""
    document = message.document
    file_name = document.file_name
    file_extension = file_name.split('.')[-1].lower()

    supported_formats = {"pdf", "docx", "txt", "epub"}

    if file_extension not in supported_formats:
        await message.reply("Ошибка: неподдерживаемый формат файла. Пожалуйста, отправьте PDF, DOCX, TXT или EPUB.")
        return

    # Загрузка файла
    file_path = f"{file_name}"
    await document.download(destination_file=file_path)
    await message.reply("Файл получен. Обрабатываем...")

    # Извлечение текста из файла
    try:
        if file_extension == "pdf":
            text = extract_text_from_pdf(file_path)
        elif file_extension == "docx":
            text = extract_text_from_docx(file_path)
        elif file_extension == "txt":
            text = extract_text_from_txt(file_path)
        elif file_extension == "epub":
            text = extract_text_from_epub(file_path)
        else:
            await message.reply("Ошибка: неподдерживаемый формат файла.")
            return
    except Exception as e:
        logging.error(f"Ошибка при извлечении текста: {e}")
        await message.reply("Ошибка при извлечении текста из файла.")
        return

    # Отправка текста на сервер для обработки
    summary = await send_text_to_server(text)
    await message.reply(f"Краткое содержание:\n\n{summary}")

    # Удаление файла после обработки
    os.remove(file_path)


@router.message(types.Message.text)
async def handle_text_message(message: types.Message):
    """Обрабатывает текстовые сообщения, не являющиеся командами."""
    text = message.text

    if text.startswith("/"):
        await message.reply("Пожалуйста, используйте эту команду корректно или отправьте текст для суммаризации.")
        return

    # Отправка текста на сервер для получения краткого содержания
    await message.reply("Обрабатываем текст...")
    summary = await send_text_to_server(text)
    await message.reply(f"Краткое содержание:\n\n{summary}")


async def main():
    """Запускает бота."""
    dp.include_router(router)
    await bot.delete_webhook(drop_pending_updates=True)
    await dp.start_polling(bot)


if __name__ == "__main__":
    asyncio.run(main())