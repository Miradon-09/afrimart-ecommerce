import React from 'react';

const ProductCard = ({ product }) => {
    return (
        <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-300">
            <div className="h-48 overflow-hidden bg-gray-200">
                <img
                    src={product.imageUrl || 'https://via.placeholder.com/300x200?text=No+Image'}
                    alt={product.name}
                    className="w-full h-full object-cover"
                />
            </div>
            <div className="p-4">
                <div className="flex justify-between items-start mb-2">
                    <h3 className="text-lg font-semibold text-gray-800 line-clamp-1">{product.name}</h3>
                    <span className="bg-primary-100 text-primary-800 text-xs font-medium px-2.5 py-0.5 rounded">
                        {product.category}
                    </span>
                </div>
                <p className="text-gray-600 text-sm mb-4 line-clamp-2 h-10">{product.description}</p>
                <div className="flex justify-between items-center">
                    <span className="text-xl font-bold text-primary-600">
                        ₦{product.price.toLocaleString()}
                    </span>
                    <button className="bg-primary-600 hover:bg-primary-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors">
                        Add to Cart
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ProductCard;
