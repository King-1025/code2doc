FROM python:3

WORKDIR /opt/code2doc

COPY ./script/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt && rm -rf requirements.txt

COPY . .

ENTRYPOINT ["/opt/code2doc/code.sh"]

CMD ["-h"]
