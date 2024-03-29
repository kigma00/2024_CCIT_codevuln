import Link from "next/link"
import React from "react"

const Header = () => {
  return (
    <>
      <header className="bg-white shadow-md fixed w-screen">
        <nav className="container mx-auto px-6 py-3 flex justify-between items-center">
          <a
            className="text-2xl md:text-3xl font-bold flex flex-row items-center"
            href="/"
          >
            <img src="/codevuln.png" class="h-8 md:h-10 mr-1" />
            CodeVuln
          </a>
          <div className="space-x-4 text-gray-500 font-normal md:text-lg text:md">
            <Link
              href="/"
              className="text-gray-500 border-2 border-transparent rounded-lg mr-1 px-2 py-1 hover:bg-gray-100"
            >
              menu
            </Link>
            <Link
              href="/"
              className="text-gray-500 border-2 border-transparent rounded-lg mr-1 px-2 py-1 hover:bg-gray-100"
            >
              menu
            </Link>
            <Link
              href="/"
              className="text-gray-500 border-2 border-transparent rounded-lg mr-1 px-2 py-1 hover:bg-gray-100"
            >
              menu
            </Link>
            <Link
              href="/"
              className="text-gray-500 border-2 border-transparent rounded-lg mr-1 px-2 py-1 hover:bg-gray-100"
            >
              menu
            </Link>
          </div>
        </nav>
      </header>
    </>
  )
}

export default Header
