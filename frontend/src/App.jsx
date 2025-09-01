import { Routes, Route } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import Navbar from './components/Navbar'
import Home from './pages/Home'
import Search from './pages/Search'
import Submit from './pages/Submit'
import Review from './pages/Review'
import Profile from './pages/Profile'
import WordDetail from './pages/WordDetail'

function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      
      <main className="container mx-auto px-4 py-8">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/search" element={<Search />} />
          <Route path="/submit" element={<Submit />} />
          <Route path="/review" element={<Review />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/word/:id" element={<WordDetail />} />
        </Routes>
      </main>
      
      <Toaster position="top-right" />
    </div>
  )
}

export default App
