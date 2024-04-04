"use client"

import { useState } from "react"
import Link from "next/link"

// const getRepoInfo = async (repoName) => {
//   try {
//     const response = await fetch(
//       `https://api.github.com/search/repositories?q=${repoName}`
//     )
//     if (!response.ok) {
//       throw new Error("검색 결과를 가져올 수 없습니다.")
//     }
//     const data = await response.json()
//     return data.items
//   } catch (error) {
//     console.error("API 호출 중 오류 발생:", error)
//     return null
//   }
// }

const CourseSearch = ({ getSearchResults }) => {
  const [query, setQuery] = useState("")
  const [repos, setRepos] = useState([])
  const [selectedRepo, setSelectedRepo] = useState(null)
  const [errorMessage, setErrorMessage] = useState(null)

  // const handleSubmit = async (e) => {
  //   e.preventDefault()
  //   try {
  //     const repoInfo = await getRepoInfo(query)
  //     if (repoInfo && repoInfo.length > 0) {
  //       setRepos(repoInfo)
  //       setErrorMessage(null)
  //     } else {
  //       throw new Error("검색 결과가 없습니다.")
  //     }
  //   } catch (error) {
  //     console.error("레포지토리 검색 중 오류 발생:", error)
  //     setRepos([])
  //     setSelectedRepo(null)
  //     setErrorMessage(error.message)
  //   }
  // }

  return (
    <>
      <div className="h-24 w-screen"></div>
      <div className="flex w-screen h-screen">
        <div className="flex h-3/5 mx-20 w-screen px-20">
          <div className="h-full w-2/6 flex flex-col">
            <div className="flex flex-row w-full justify-between">
              <div className="w-1/2 bg-sky-300 flex justify-end rounded-t-3xl h-16"></div>
              <div className="w-1/2 justify-end flex items-start">
                <div className="flex justify-center items-center font-bold text-xl bg-sky-300 rounded-full h-12 w-full ml-4 mb-2">
                  CodeQL
                </div>
              </div>
            </div>

            <div className="flex flex-col w-full bg-sky-300 h-full rounded-r-3xl justify-center items-center pt-4">
              <img src="/codeql2.png" className="w-5/6 aspect-w-5 aspect-h-5" />
              <span className="font-bold text-xl">Analysis with CodeQL.</span>
            </div>

            <div className="flex flex-row w-full justify-end">
              <div className="bg-sky-300 w-full rounded-b-3xl"></div>
              <div className="p-3">
                <Link href="/codeql">
                  <div className="bg-black w-14 h-14 rounded-full hover:bg-neutral-900 flex justify-center items-center">
                    <img src="/arrow.png" className="h-10 bg-transparent"></img>
                  </div>
                </Link>
              </div>
            </div>
          </div>

          <div className="h-full w-2/6 flex flex-col mx-8">
            <div className="flex flex-row w-full justify-between">
              <div className="w-1/2 bg-emerald-200 flex justify-end rounded-t-3xl h-16"></div>
              <div className="w-1/2 justify-end flex items-start">
                <div className="flex justify-center items-center font-bold text-xl bg-emerald-200 rounded-full h-12 w-full ml-4 mb-2">
                  Semgrep
                </div>
              </div>
            </div>

            <div className="flex flex-col w-full bg-emerald-200 h-full rounded-r-3xl justify-center items-center pt-4">
              <img src="/semgrep.png" className="w-5/6 aspect-w-5 aspect-h-5" />
              <span className="font-bold text-xl">Analysis with Semgrep.</span>
            </div>

            <div className="flex flex-row w-full justify-end">
              <div className="bg-emerald-200 w-full rounded-b-3xl"></div>
              <div className="p-3">
                <Link href="/semgrepcsv">
                  <div className="bg-black w-14 h-14 rounded-full hover:bg-neutral-900 flex justify-center items-center">
                    <img src="/arrow.png" className="h-10 bg-transparent"></img>
                  </div>
                </Link>
              </div>
            </div>
          </div>

          <div className="h-full w-2/6 flex flex-col">
            <div className="flex flex-row w-full justify-between">
              <div className="w-1/2 bg-zinc-400 flex justify-end rounded-t-3xl h-16"></div>
              <div className="w-1/2 justify-end flex items-start">
                <div className="flex justify-center items-center font-bold text-xl bg-zinc-400 rounded-full h-12 w-full ml-4 mb-2">
                  SonarQube
                </div>
              </div>
            </div>

            <div className="flex flex-col w-full bg-zinc-400 h-full rounded-r-3xl justify-center items-center pt-4">
              <div className="w-5/6 aspect-w-5 aspect-h-5">
                <img src="/sonarqube4.png" />
              </div>
              <span className="font-bold text-xl">
                Analysis with SonarQube.
              </span>
            </div>

            <div className="flex flex-row w-full justify-end">
              <div className="bg-zinc-400 w-full rounded-b-3xl"></div>
              <div className="p-3">
                <Link href="/next-page">
                  <div className="bg-black w-14 h-14 rounded-full hover:bg-neutral-900 flex justify-center items-center">
                    <img src="/arrow.png" className="h-10 bg-transparent"></img>
                  </div>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}

export default CourseSearch
