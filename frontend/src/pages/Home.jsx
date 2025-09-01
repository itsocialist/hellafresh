import { Link } from 'react-router-dom'
import { MagnifyingGlassIcon, PlusIcon, FireIcon, ChartBarIcon, MapPinIcon, UserGroupIcon } from '@heroicons/react/24/outline'

const features = [
  {
    name: 'Track Origins',
    description: 'Claim ownership of new slang terms and track their cultural origins',
    icon: MapPinIcon,
  },
  {
    name: 'Community Verified',
    description: 'Three-person community review system ensures authenticity',
    icon: UserGroupIcon,
  },
  {
    name: 'NFT Ownership',
    description: 'Approved words get minted as NFTs on the XRP Ledger',
    icon: FireIcon,
  },
  {
    name: 'Cultural Analytics',
    description: 'See how words spread across regions and communities',
    icon: ChartBarIcon,
  },
]

const trendingWords = [
  { word: 'bussin', definition: 'Extremely good or delicious', status: 'minted' },
  { word: 'no cap', definition: 'No lie, telling the truth', status: 'minted' },
  { word: 'periodt', definition: 'End of discussion', status: 'minted' },
  { word: 'salty', definition: 'Being bitter about something', status: 'minted' },
]

export default function Home() {
  return (
    <div className="space-y-16">
      {/* Hero Section */}
      <section className="text-center space-y-8">
        <div className="space-y-4">
          <h1 className="text-4xl sm:text-6xl font-bold">
            Own Your{' '}
            <span className="text-gradient">Slang</span>
          </h1>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Track when and where slang terms originate. Claim ownership of new words 
            and trace the cultural evolution of language across communities.
          </p>
        </div>
        
        <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
          <Link to="/search" className="btn-primary flex items-center">
            <MagnifyingGlassIcon className="w-5 h-5 mr-2" />
            Explore Words
          </Link>
          <Link to="/submit" className="btn-secondary flex items-center">
            <PlusIcon className="w-5 h-5 mr-2" />
            Submit a Word
          </Link>
        </div>
      </section>

      {/* Stats Section */}
      <section className="bg-white rounded-2xl p-8 shadow-sm border border-gray-200">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
          <div>
            <div className="text-3xl font-bold text-blue-600">1,247</div>
            <div className="text-gray-600">Words Tracked</div>
          </div>
          <div>
            <div className="text-3xl font-bold text-green-600">892</div>
            <div className="text-gray-600">NFTs Minted</div>
          </div>
          <div>
            <div className="text-3xl font-bold text-purple-600">156</div>
            <div className="text-gray-600">Cities Covered</div>
          </div>
          <div>
            <div className="text-3xl font-bold text-orange-600">3.2k</div>
            <div className="text-gray-600">Community Members</div>
          </div>
        </div>
      </section>

      {/* Trending Words */}
      <section className="space-y-6">
        <div className="text-center">
          <h2 className="text-3xl font-bold text-gray-900">Trending Words</h2>
          <p className="text-gray-600 mt-2">Popular slang terms making waves right now</p>
        </div>
        
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-4">
          {trendingWords.map((item) => (
            <div key={item.word} className="word-card group">
              <div className="flex items-start justify-between mb-3">
                <h3 className="text-lg font-semibold text-gray-900 group-hover:text-blue-600 transition-colors">
                  {item.word}
                </h3>
                <span className="tag tag-status">
                  {item.status}
                </span>
              </div>
              <p className="text-gray-600 text-sm">{item.definition}</p>
            </div>
          ))}
        </div>
        
        <div className="text-center">
          <Link to="/search" className="text-blue-600 hover:text-blue-800 font-medium">
            View all words →
          </Link>
        </div>
      </section>

      {/* Features Section */}
      <section className="space-y-12">
        <div className="text-center">
          <h2 className="text-3xl font-bold text-gray-900">How It Works</h2>
          <p className="text-gray-600 mt-2 max-w-2xl mx-auto">
            Track the evolution of language through blockchain-verified ownership and community validation
          </p>
        </div>
        
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {features.map((feature) => {
            const Icon = feature.icon
            return (
              <div key={feature.name} className="text-center space-y-4">
                <div className="w-12 h-12 bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg flex items-center justify-center mx-auto">
                  <Icon className="w-6 h-6 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900">{feature.name}</h3>
                <p className="text-gray-600 text-sm">{feature.description}</p>
              </div>
            )
          })}
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-gradient-to-r from-blue-600 to-purple-600 rounded-2xl p-8 text-center text-white">
        <h2 className="text-3xl font-bold mb-4">Ready to Make History?</h2>
        <p className="text-lg mb-6 opacity-90">
          Be part of documenting the cultural evolution of language. 
          Submit your word, get community approval, and mint your NFT.
        </p>
        <Link to="/submit" className="bg-white text-blue-600 font-semibold py-3 px-6 rounded-lg hover:bg-gray-100 transition-colors">
          Submit Your First Word
        </Link>
      </section>
    </div>
  )
}
