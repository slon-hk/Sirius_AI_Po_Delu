import os
import shutil
import logging
import csv
from Levenshtein import ratio
from ebooklib import epub
from selenium import webdriver
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException
from tika import parser
from datasets import Dataset
import pandas as pd

# Настройка логирования
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

url = "https://briefly.ru/"
id_counter = 0

# Задаем путь для CSV файла
csv_file_path = '/Users/leonidstepanov/Desktop/Project/AI/books_dataset.csv'
headers = ['ID', 'Title', 'Author', 'Summary', 'Full Text']

# Инициализация браузера
def init_driver():
    """Инициализирует веб-драйвер для браузера Firefox."""
    options = FirefoxOptions()
    options.add_argument("--headless")
    options.set_preference("permissions.default.image", 2)
    options.set_preference("dom.webnotifications.enabled", False)
    options.set_preference("privacy.trackingprotection.enabled", True)
    driver = webdriver.Firefox(service=FirefoxService(executable_path="/Users/leonidstepanov/Desktop/Project/AI/geckodriver"), options=options)
    return driver


def get_data():
    """Получает данные о книге с веб-сайта."""
    global id_counter
    driver = init_driver()
    row_data = []

    try:
        driver.get(url=url)

        reg_btn = WebDriverWait(driver, 5).until(EC.element_to_be_clickable((By.XPATH, "/html/body/header/div/nav/ul/li[7]/a")))
        reg_btn.click()

        # Получаем данные о книге
        book_title = get_title(driver)
        book_author = get_author(driver)
        book_summary = get_summary(driver)
        book_text = get_full_text(driver, book_author, book_title)

        # Проверка на наличие всех данных
        if all([book_title, book_author, book_summary, book_text]):
            logging.info("Данные получены успешно.")
            row_data = [id_counter, book_title, book_author, book_summary, book_text]
            id_counter += 1  # Инкрементируем ID для каждой книги
        else:
            logging.warning("Некоторые данные книги отсутствуют.")

    except KeyboardInterrupt:
        logging.info("Программа остановлена пользователем.")
        driver.quit()
        exit(0)
    except Exception as e:
        logging.error(f"Ошибка в main(): {e}")
    finally:
        driver.quit()

    return row_data


def get_title(driver):
    """Получает название книги."""
    try:
        return WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.ID, "title"))).text.strip()
    except Exception as e:
        logging.error(f"Ошибка при получении названия книги: {e}")
        return None


def get_author(driver):
    """Получает имя автора книги."""
    try:
        return WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.CLASS_NAME, "breadcrumb__name"))).text.strip()
    except Exception as e:
        logging.error(f"Ошибка при получении автора книги: {e}")
        return None


def get_summary(driver):
    """Получает краткое содержание книги."""
    try:
        text = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "text"))).text
        return text.replace("РЕКЛАМА", "").strip()
    except Exception as e:
        logging.error(f"Ошибка при получении сжатого текста: {e}")
        return None


def get_full_text(driver, author, title):
    """Получает полный текст книги."""
    url_full_text = "https://royallib.com/"
    driver.get(url_full_text)
    driver.find_element(By.ID, "q").send_keys(f"{author} {title}")
    driver.find_element(By.XPATH, "/html/body/div[2]/div/div[2]/div[1]/form/input[3]").click()

    try:
        book_title = driver.find_element(By.XPATH, "/html/body/div[2]/div/div[2]/div[2]/div/table/tbody/tr[3]/td/table/tbody/tr[2]/td[1]/a")
        if ratio(book_title.text, title) >= 0.85:
            book_title.click()
        else:
            logging.error("Название книги не найдено")
            return None
    except NoSuchElementException:
        logging.error("Книга не найдена")
        return None

    try:
        driver.find_element(By.XPATH, "//html/body/div[2]/div/div[2]/div[2]/div/table[3]/tbody/tr/td[2]/a[6]").click()
    except NoSuchElementException:
        logging.error("Файл для скачивания не найден")
        return None

    download_dir = "/Users/leonidstepanov/Downloads/"
    extract_dir = "/Users/leonidstepanov/Documents/project/SiriusAI_Po_Delu/AI/create datasets/open_zip"
    latest_epub = find_latest_file(download_dir, ('.epub',))

    if latest_epub:
        logging.info(f"Найден EPUB документ: {latest_epub}")
        move_file(latest_epub, extract_dir)
        moved_epub = os.path.join(extract_dir, os.path.basename(latest_epub))
        text = read_epub(moved_epub)
        return text
    else:
        logging.error("EPUB файл не найден в директории загрузок.")
    
    return None


def move_file(src, dst):
    """Перемещает файл из одной директории в другую."""
    try:
        shutil.move(src, dst)
        logging.info(f"Файл {src} успешно перемещен в {dst}")
    except Exception as e:
        logging.error(f"Ошибка при перемещении файла: {e}")


def read_epub(file_path):
    """Читает содержимое EPUB файла и сохраняет его в текстовый файл."""
    try:
        parsed = parser.from_file(file_path)
        content = parsed.get("content", "")
        text_file_path = os.path.splitext(file_path)[0] + ".txt"
        with open(text_file_path, 'w', encoding='utf-8') as fout:
            fout.write(content)
        return content
    except Exception as e:
        logging.error(f"Ошибка при чтении EPUB файла: {e}")
        return None


def find_latest_file(directory, file_types):
    """Находит последний измененный файл в указанной директории."""
    files = [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith(file_types)]
    latest_file = max(files, key=os.path.getctime) if files else None
    return latest_file

with open(csv_file_path, mode='a', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(headers)

# Сбор данных и запись в CSV
data = []
for _ in range(1000):
    row = get_data()
    if row:
        data.append({
            'id': row[0],
            'title': row[1],
            'author': row[2],
            'summary': row[3],
            'text': row[4]
        })
        # Добавляем строку в CSV файл
        with open(csv_file_path, mode='a', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            writer.writerow(row)

# Конвертация данных в DataFrame для создания набора данных
df = pd.DataFrame(data)
dataset = Dataset.from_pandas(df)

# Опционально разбиваем на обучающую и тестовую выборки
dataset = dataset.train_test_split(test_size=0.2)

print(dataset)