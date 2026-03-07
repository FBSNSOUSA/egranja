interface LoadingSkeletonProps {
  type?: 'cards' | 'table' | 'chart' | 'detail';
  count?: number;
}

function SkeletonPulse({ className }: { className: string }) {
  return <div className={`animate-pulse bg-gray-200 rounded ${className}`} />;
}

export default function LoadingSkeleton({
  type = 'cards',
  count = 4,
}: LoadingSkeletonProps) {
  if (type === 'cards') {
    return (
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {Array.from({ length: count }).map((_, i) => (
          <div key={i} className="card space-y-3">
            <SkeletonPulse className="h-4 w-1/2" />
            <SkeletonPulse className="h-8 w-2/3" />
            <SkeletonPulse className="h-3 w-3/4" />
          </div>
        ))}
      </div>
    );
  }

  if (type === 'table') {
    return (
      <div className="card p-0 overflow-hidden">
        <div className="p-4 border-b border-gray-100">
          <SkeletonPulse className="h-10 w-64" />
        </div>
        <div className="p-4 space-y-3">
          <SkeletonPulse className="h-8 w-full" />
          {Array.from({ length: count }).map((_, i) => (
            <SkeletonPulse key={i} className="h-12 w-full" />
          ))}
        </div>
      </div>
    );
  }

  if (type === 'chart') {
    return (
      <div className="card">
        <SkeletonPulse className="h-5 w-1/3 mb-4" />
        <SkeletonPulse className="h-64 w-full" />
      </div>
    );
  }

  if (type === 'detail') {
    return (
      <div className="space-y-6">
        <div className="card space-y-4">
          <SkeletonPulse className="h-6 w-1/3" />
          <div className="grid grid-cols-3 gap-4">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="space-y-2">
                <SkeletonPulse className="h-3 w-1/2" />
                <SkeletonPulse className="h-5 w-3/4" />
              </div>
            ))}
          </div>
        </div>
        <div className="card">
          <SkeletonPulse className="h-64 w-full" />
        </div>
      </div>
    );
  }

  return null;
}
