from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models import Product
from app.config import *

engine = create_engine(mysql_server)
session = sessionmaker(bind=engine)()
