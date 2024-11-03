import pandas as pd

file_path = '/Users/leonidstepanov/Desktop/Project/AI/books_dataset.csv'
output_path = '/Users/leonidstepanov/Desktop/Project/AI/cleaned_books_dataset.csv'


books_data = pd.read_csv(file_path)


books_data['ID'] = range(1, len(books_data) + 1)

books_data['Full Text'] = books_data['Full Text'].str.replace("""Спасибо, что скачали книгу в бесплатной электронной библиотеке Royallib.com
Все книги автора
Эта же книга в других форматах

Приятного чтения!
""", "", regex=False)


books_data['Full Text'] = books_data['Full Text'].str.replace("""Спасибо, что скачали книгу в бесплатной электронной библиотеке Royallib.com
Оставить отзыв о книге
Все книги автора""", "", regex=False)
# Сохраняем очищенные данные в новый CSV файл
books_data.to_csv(output_path, index=False, encoding='utf-8')

print(f"Данные успешно очищены и сохранены в {output_path}")