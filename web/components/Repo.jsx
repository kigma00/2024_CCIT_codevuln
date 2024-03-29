import { github_user } from '@/const/const'
import Link from 'next/link'
import React from 'react'
import { FaStar, FaCodeBranch, FaEye } from 'react-icons/fa'

// const username = 'bradtraversy'
// const github_user = username

async function fetchRepo(name) {
  const username = 'bradtraversy'

  const url = `https://api.github.com/repos/${username}/${name}`
  const response = await fetch(
    `https://api.github.com/repos/${username}/${name}`
  )
  const repo = await response.json()
  await new Promise((resolve) => setTimeout(resolve, 1000))
  return repo
}

const Repo = async ({ name }) => {
  const repo = await fetchRepo(name)
  const username = 'bradtraversy'

  return (
    <div>
      <h3 className="text-xl font-bold">
        <Link href={`https://github.com/${username}/${name}`}>{repo.name}</Link>
      </h3>
      <p>{repo.description}</p>
      <div className="flex justify-between items-center mb-4">
        <span className="flex items-center gap-1">
          <FaStar /> {repo.stargazers_count}
        </span>
        <span className="flex items-center gap-1">
          <FaCodeBranch /> {repo.forks_count}
        </span>
        <span className="flex items-center gap-1">
          <FaEye /> {repo.stargazers_count}
        </span>
      </div>
    </div>
  )
}

export default Repo
