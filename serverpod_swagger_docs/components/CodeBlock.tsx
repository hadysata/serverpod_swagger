import React from 'react';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { atomDark } from 'react-syntax-highlighter/dist/cjs/styles/prism';

interface CodeBlockProps {
  language: string;
  code: string;
  showLineNumbers?: boolean;
  fileName?: string;
}

const CodeBlock: React.FC<CodeBlockProps> = ({
  language,
  code,
  showLineNumbers = true,
  fileName,
}) => {
  return (
    <div className="rounded-lg overflow-hidden my-4">
      {fileName && (
        <div className="bg-gray-800 text-gray-200 px-4 py-2 text-sm font-mono border-b border-gray-700">
          {fileName}
        </div>
      )}
      <SyntaxHighlighter
        language={language}
        style={atomDark}
        showLineNumbers={showLineNumbers}
        wrapLines={true}
        customStyle={{
          margin: 0,
          borderRadius: fileName ? '0 0 0.5rem 0.5rem' : '0.5rem',
        }}
      >
        {code}
      </SyntaxHighlighter>
    </div>
  );
};

export default CodeBlock;