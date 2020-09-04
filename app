from flask import Flask, request, render_template
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

from app.config import mysql_server
from app.models import Product

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = mysql_server

db = SQLAlchemy(app)

@app.route("/api", methods=["POST"])
def register_product():

    if not request.args:
        return "Error: No URI path parameters"
		
    else:
        if all(i in request.args for i in ["SKU", "Name", "Qty", "Price"]):
            product = request.args.to_dict()           
            if product["SKU"] in [i[0] for i in db.session.query(Product.sku)]:
                return f'Error: {product["SKU"]} already exists!'
            else:
                    try:
                        db.session.add(Product(product["SKU"], product["Name"], product["Qty"], product["Price"]))
                        db.session.commit()
                        return f"Success: Added {str(request.args.to_dict())}"
                    except:
                        db.session.rollback()
                        return f"Error: Could not add {str(request.args.to_dict())}"
        else:
            return "Error: Missing URI path parameter(s)"

#    if not request.data:
#        print("Error: No data")
#    else:
#        print(request.data)
#        return request.data
#    return "Error: No URI path parameters nor data"

@app.route("/api/<sku>", methods=["GET"])
def retreive(sku):

    if request.method == "GET":
        if sku in [i[0] for i in db.session.query(Product.sku)]:
            product = db.session.query(Product).filter(Product.sku == sku).one()
            return str({"SKU": product.sku, "Name": product.name, "Qty": product.qty, "Price": product.price})
        else:
            return f"Error: Could not find product with SKU {sku}"

@app.route("/api/<sku>", methods=["PUT"])
def register_quantity(sku):

    if request.method == "PUT":
        if sku in [i[0] for i in db.session.query(Product.sku)]:
            product = db.session.query(Product).filter(Product.sku == sku).one()

            if request.args.get("plus"):
                try:
                    qty_from = product.qty
                    product.qty += int(request.args.get("plus"))
                    qty_to = product.qty
                    db.session.commit()
                    return "Updated quantity from: " + str(qty_from) + " to: " + str(qty_to)
                except:
                    db.session.rollback()
                    return "Error: Could not update"

            elif request.args.get("minus"):
                try:
                    qty_from = product.qty
                    product.qty -= int(request.args.get("minus"))
                    qty_to = product.qty
                    db.session.commit()
                    return f"Updated quantity from: {str(qty_from)} to: {str(qty_to)}"
                except:
                    db.session.rollback()
                    return "Error: Could not update"

            else:
                return 'Error: URI path parameters needed (i.e. arguments "plus=" or "minus="'

        else:
            return f"Error: Could not find product with SKU {sku}"
			
@app.route("/api/available", methods=["GET"])
def list_available():

    avail = db.session.query(Product).filter(Product.qty > 0).all()
    return str([{"SKU": i.sku, "Name": i.name, "Qty": i.qty, "Price": i.price} for i in avail])

@app.route("/api/sold-out", methods=["GET"])
def list_sold_out():

    sold_out = db.session.query(Product).filter(Product.qty == 0).all()
    return str([{"SKU": i.sku, "Name": i.name, "Qty": i.qty, "Price": i.price} for i in sold_out])

if __name__ == "__main__":
        app.run()
