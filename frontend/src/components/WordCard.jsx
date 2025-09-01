import { Link } from 'react-router-dom'
import { 
  MapPinIcon, 
  CalendarIcon, 
  TagIcon,
  CheckBadgeIcon,
  ClockIcon,
  XCircleIcon,
  SparklesIcon 
} from '@heroicons/react/24/outline'

const statusConfig = {
  pending: {
    icon: ClockIcon,
    label: 'Pending Review',
    color: 'text-yellow-600',
    bgColor: 'bg-yellow-100',
    cardClass: 'status-pending'
  },
  under_review: {
    icon: ClockIcon,
    label: 'Under Review',
    color: 'text-orange-600',
    bgColor: 'bg-orange-100',
    cardClass: 'status-pending'
  },
  approved: {
    icon: CheckBadgeIcon,
    label: 'Approved',
    color: 'text-green-600',
    bgColor: 'bg-green-100',
    cardClass: 'status-approved'
  },
  minted: {
    icon: SparklesIcon,
    label: 'NFT Minted',
    color: 'text-purple-600',
    bgColor: 'bg-purple-100',
    cardClass: 'status-minted'
  },
  rejected: {
    icon: XCircleIcon,
    label: 'Rejected',
    color: 'text-red-600',
    bgColor: 'bg-red-100',
    cardClass: 'status-rejected'
  }
}

export default function WordCard({ word, showDetails = true, className = "" }) {
  const status = statusConfig[word.status] || statusConfig.pending
  const StatusIcon = status.icon

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  }

  return (
    <Link to={`/word/${word.id}`} className={`block ${className}`}>
      <div className={`word-card ${status.cardClass}`}>
        {/* Header with word and status */}
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <h3 className="text-lg font-semibold text-gray-900 group-hover:text-blue-600 transition-colors">
              {word.word}
            </h3>
            {word.pronunciation_audio_url && (
              <button 
                className="text-xs text-gray-500 hover:text-gray-700 mt-1"
                onClick={(e) => {
                  e.preventDefault()
                  // TODO: Play pronunciation audio
                }}
              >
                🔊 Play pronunciation
              </button>
            )}
          </div>
          
          <div className={`flex items-center px-2 py-1 rounded-full ${status.bgColor} ${status.color}`}>
            <StatusIcon className="w-3 h-3 mr-1" />
            <span className="text-xs font-medium">{status.label}</span>
          </div>
        </div>

        {/* Definition */}
        <p className="text-gray-700 mb-4 line-clamp-2">
          {word.definition}
        </p>

        {/* Usage example */}
        {word.usage_example && (
          <div className="mb-4 p-2 bg-gray-50 rounded-lg">
            <p className="text-sm text-gray-600 italic">
              "{word.usage_example}"
            </p>
          </div>
        )}

        {showDetails && (
          <div className="space-y-2">
            {/* Tags */}
            {word.tags && word.tags.length > 0 && (
              <div className="flex flex-wrap gap-1">
                {word.tags.slice(0, 3).map((tag) => (
                  <span key={tag} className="tag">
                    {tag}
                  </span>
                ))}
                {word.tags.length > 3 && (
                  <span className="tag">
                    +{word.tags.length - 3} more
                  </span>
                )}
              </div>
            )}

            {/* Metadata */}
            <div className="flex flex-wrap gap-4 text-xs text-gray-500">
              {word.origin_location && (
                <div className="flex items-center">
                  <MapPinIcon className="w-3 h-3 mr-1" />
                  {word.origin_location}
                </div>
              )}
              
              {word.submitted_at && (
                <div className="flex items-center">
                  <CalendarIcon className="w-3 h-3 mr-1" />
                  {formatDate(word.submitted_at)}
                </div>
              )}
              
              {word.category && (
                <div className="flex items-center">
                  <TagIcon className="w-3 h-3 mr-1" />
                  {word.category}
                </div>
              )}
            </div>

            {/* Cultural context hint */}
            {word.cultural_context && (
              <p className="text-xs text-gray-600 italic mt-2 line-clamp-1">
                {word.cultural_context}
              </p>
            )}
          </div>
        )}

        {/* NFT indicator for minted words */}
        {word.status === 'minted' && word.nft_token_id && (
          <div className="mt-3 pt-3 border-t border-purple-200">
            <div className="flex items-center justify-between">
              <span className="text-xs text-purple-600 font-medium">
                NFT: {word.nft_token_id}
              </span>
              <button className="text-xs text-purple-600 hover:text-purple-800">
                View on XRPL →
              </button>
            </div>
          </div>
        )}
      </div>
    </Link>
  )
}
