'use client'

import { useState } from 'react'

const CourseSearch = ({ getSearchResults }) => {
  const [query, setQuery] = useState('')

  const handleSubmit = async (e) => {
    e.preventDefault()
    //console.log(query)

    const res = await fetch(`/api/courses/search?query=${query}`)
    const courses = await res.json()
    getSearchResults(courses)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        placeholder="제목 키워드 검색"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        className="bg-red-100 py-2 px-4 m-2 rounded-lg"
      />
      <button
        type="submit"
        className="p-2 m-2 text-white bg-pink-700 hover:bg-pink-800 rounded-lg"
      >
        Search
      </button>
    </form>
  )
}
export default CourseSearch
