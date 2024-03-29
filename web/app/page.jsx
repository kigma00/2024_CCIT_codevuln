"use client"

import Link from "next/link"
import { useState } from "react"

const getRepoInfo = async (repoName) => {
  try {
    const response = await fetch(
      `https://api.github.com/search/repositories?q=${repoName}`
    )
    if (!response.ok) {
      throw new Error("검색 결과를 가져올 수 없습니다.")
    }
    const data = await response.json()
    return data.items
  } catch (error) {
    console.error("API 호출 중 오류 발생:", error)
    return null
  }
}

const CourseSearch = ({ getSearchResults }) => {
  const [query, setQuery] = useState("")
  const [repos, setRepos] = useState([])
  const [selectedRepo, setSelectedRepo] = useState(null)
  const [errorMessage, setErrorMessage] = useState(null)

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      const repoInfo = await getRepoInfo(query)
      if (repoInfo && repoInfo.length > 0) {
        setRepos(repoInfo)
        setErrorMessage(null)
      } else {
        throw new Error("No search results.")
      }
    } catch (error) {
      console.error("Error searching repository:", error)
      setRepos([])
      setSelectedRepo(null)
      setErrorMessage(error.message)
    }
  }

  const handleSelectRepo = (repo) => {
    setSelectedRepo(repo)
  }

  return (
    <div>
      <form
        onSubmit={handleSubmit}
        className="flex md:justify-center flex-row items-center"
      >
        <input
          type="text"
          placeholder="Search Repository Name"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="bg-white py-2 md:py-3 pl-10 md:pr-80 pr-40 m-2 rounded-full border-2 border-blue-500 focus:border-blue-500 focus:outline-none  focus:ring-blue-500"
        />
        <button
          type="submit"
          className="p-2 m-2 text-white bg-blue-600 hover:bg-blue-700 rounded-full"
        >
          <img src="/searchicon.png" className="w-6 md:w-10 p-1" />
        </button>
      </form>
      {errorMessage && <p className="text-red-500">{errorMessage}</p>}
      {repos.length > 0 && (
        <div>
          <br></br>
          <h2 className="text-xl font-bold">Search Results</h2>
          <br></br>
          <ul className="space-y-4">
            {repos.map((repo, index) => (
              <li key={index} className="p-4 border border-gray-300 rounded-lg">
                <input
                  type="checkbox"
                  checked={selectedRepo === repo}
                  onChange={() => handleSelectRepo(repo)}
                  className="mr-2"
                  style={{ width: "1rem", height: "1rem" }}
                />

                <label
                  className="font-bold"
                  onClick={() => handleSelectRepo(repo)}
                >
                  {repo.full_name}
                </label>
                {selectedRepo === repo && (
                  <div className="bg-gray-100 p-4 mt-2 rounded-lg font-bold text-gray-500">
                    <h2 className="text-xl text-blue-700">Repository info</h2>
                    <p>Name: {selectedRepo.full_name}</p>
                    <p>Description: {selectedRepo.description}</p>
                    <p>
                      URL:{" "}
                      <a href={selectedRepo.html_url}>
                        🔗{selectedRepo.html_url}
                      </a>
                    </p>
                    <br></br>
                    <div className="flex justify-end items-center">
                      <Link href="/select">
                        <img src="/nexticon.png" className="w-10" />
                      </Link>
                    </div>
                  </div>
                )}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}

export default function Home() {
  const [searchResults, setSearchResults] = useState(null)

  const getSearchResults = (results) => {
    setSearchResults(results)
  }

  return (
    <>
      <CourseSearch getSearchResults={getSearchResults} />
    </>
  )
}
