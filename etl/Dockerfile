FROM prefecthq/prefect:2.7.7-python3.9

RUN pip install -U pip
RUN pip install pipenv

COPY ["Pipfile", "Pipfile.lock", "./"]

RUN pipenv install --system --deploy
