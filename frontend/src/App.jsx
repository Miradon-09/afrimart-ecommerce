import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import ProductList from './components/ProductList';

function App() {
  return (
    <Router>
      <div className="min-h-screen">
        <header className="bg-white shadow">
          <div className="max-w-7xl mx-auto px-4 py-6">
            <h1 className="text-3xl font-bold text-primary-600">
              AfriMart E-Commerce
            </h1>
            <p className="text-gray-600 mt-2">
              Full-Stack Application for DevOps Training
            </p>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 py-8">
          <div className="mb-8 flex justify-between items-center">
            <h2 className="text-2xl font-bold text-gray-800">Featured Products</h2>
            <div className="flex space-x-2">
              <span className="text-sm text-gray-500">Showing all sample products</span>
            </div>
          </div>

          <ProductList />
        </main>

        <ToastContainer position="top-right" autoClose={3000} />
      </div>
    </Router>
  );
}

export default App;
