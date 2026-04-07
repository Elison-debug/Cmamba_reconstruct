# Mamba for radio environment

```bash
conda create -n mamba python=3.10
conda init python-transformers
conda activate python-transformers
pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu129
```

```bash
python -c "from transformers import pipeline; print(pipeline('sentiment-analysis')('we love you'))"
```

testing transformers

```bash
 pip install torch einops numpy pandas scikit-learn matplotlib wandb 
```bash



