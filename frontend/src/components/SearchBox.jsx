import { useState } from 'react'
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline'

export default function SearchBox({ onSearch, placeholder = "Search slang words...", className = "" }) {
  const [query, setQuery] = useState('')
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!query.trim()) return
    
    setIsLoading(true)
    try {
      await onSearch(query.trim())
    } finally {
      setIsLoading(false)
    }
  }

  const handleInputChange = (e) => {
    setQuery(e.target.value)
    // TODO: Implement debounced search for real-time results
  }

  return (
    <form onSubmit={handleSubmit} className={`relative ${className}`}>
      <div className="relative">
        <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
        <input
          type="text"
          value={query}
          onChange={handleInputChange}
          placeholder={placeholder}
          className="search-box pl-10 pr-4"
          disabled={isLoading}
        />
        {isLoading && (
          <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
            <div className="spinner"></div>
          </div>
        )}
      </div>
      
      <button
        type="submit"
        className="absolute right-2 top-1/2 transform -translate-y-1/2 btn-primary px-4 py-1.5 text-sm"
        disabled={isLoading || !query.trim()}
      >
        Search
      </button>
    </form>
  )
}
