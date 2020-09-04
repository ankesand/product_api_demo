from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Table, Column, String, Integer, Float

Base = declarative_base()

class Product(Base):
    
    __tablename__ = "products"
    
    sku = Column("SKU", String(255), primary_key=True)
    name = Column("Name", String(255))
    qty = Column("Qty", Integer())
    price = Column("Price", Float())

    def __init__(self, sku, name, qty, price):

        self.sku = sku
        self.name = name
        self.qty = qty
        self.price = price
