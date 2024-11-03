from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import torch
from transformers import T5ForConditionalGeneration, T5Tokenizer

MODEL_NAME = "slonHk/PoDeluModel"
model = T5ForConditionalGeneration.from_pretrained(MODEL_NAME)
tokenizer = T5Tokenizer.from_pretrained(MODEL_NAME)
model.cuda()
model.eval()

app = FastAPI()


# Модель для входных данных
class SummarizationRequest(BaseModel):
    text: str
    n_words: int = None
    compression: float = None
    max_length: int = 1000
    min_length: int = None
    num_beams: int = 3
    do_sample: bool = False
    repetition_penalty: float = 10.0


# Функция для генерации
def summarize(
    text,
    n_words=None,
    compression=None,
    max_length=1000,
    min_length=None,
    num_beams=3,
    do_sample=False,
    repetition_penalty=10.0,
    **kwargs,
):
    if n_words:
        text = f"[{n_words}] {text}"
    elif compression:
        text = f"[{compression:.1g}] {text}"
    
    x = tokenizer(text, return_tensors="pt", padding=True).to(model.device)
    
    with torch.inference_mode():
        out = model.generate(
            **x,
            max_length=max_length,
            num_beams=num_beams,
            do_sample=do_sample,
            repetition_penalty=repetition_penalty,
            min_length=min_length,
            **kwargs,
        )
    
    return tokenizer.decode(out[0], skip_special_tokens=True)


# Определение эндпоинта API для суммаризации текста
@app.post("/summarize/")
async def summarize_text(request: SummarizationRequest):
    try:
        summary = summarize(
            text=request.text,
            n_words=request.n_words,
            compression=request.compression,
            max_length=request.max_length,
            min_length=request.min_length,
            num_beams=request.num_beams,
            do_sample=request.do_sample,
            repetition_penalty=request.repetition_penalty,
        )
        return {"summary": summary}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))