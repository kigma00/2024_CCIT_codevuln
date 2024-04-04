"use client"

import React, { useState, useEffect } from "react"
import Papa from "papaparse"

const Semgrepcsv = () => {
  const [data, setData] = useState([])

  useEffect(() => {
    async function fetchData() {
      const response = await fetch("/xss.csv")
      const reader = response.body.getReader()
      const result = await reader.read() // raw array
      const decoder = new TextDecoder("utf-8")
      const csv = decoder.decode(result.value) // the csv text
      const results = Papa.parse(csv, { header: true }) // object with { data, errors, meta }
      const rows = results.data // array of objects
      setData(rows)
    }
    fetchData()
  }, [])

  const handleDownload = () => {
    // CSV 형식으로 데이터 변환
    const csv = Papa.unparse(data)
    // Blob 객체 생성
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" })
    // URL 생성
    const url = URL.createObjectURL(blob)
    // 링크 엘리먼트 생성 및 파일 다운로드 실행
    const link = document.createElement("a")
    link.href = url
    link.setAttribute("download", "export_semgrep.csv")
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  return (
    <div>
      <h1 className="my-10 mx-32 text-3xl font-bold">Vulnerability List</h1>
      <div className="mx-32 flex justify-between">
        <table>
          <thead>
            <tr>
              <th className="px-10 items-start">Check_id</th>
              <th className="px-10 items-start">Path</th>
              <th className="px-10 items-start">Line</th>
              <th className="px-10 items-start">Message</th>
              <th>
                <button
                  onClick={handleDownload}
                  className="px-4 py-2 bg-blue-500 text-white rounded"
                >
                  Export
                </button>
              </th>
            </tr>
          </thead>
          <tbody>
            {data.map((row, index) => (
              <tr className=" border-b-2 border-neutral-600" key={index}>
                <td>{row.check_id}</td>
                <td>{row.path}</td>
                <td className="justify-center items-center">
                  {row.start_line}~{row.end_line}
                </td>
                <td>{row.message}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

export default Semgrepcsv
