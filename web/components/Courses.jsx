import Link from 'next/link'

const Courses = async ({ courses }) => {
  return (
    <div className="grid-1 ">
      {courses?.map((course) => (
        <div key={course.id} className="bg-red-100 p-4 m-4 rounded-lg">
          <h2>{course.title}</h2>
          <small>Level: {course.level}</small>
          <p className="mb-4">{course.description}</p>
          <Link
            href={course.link}
            target="_blank"
            className="py-2 px-4 bg-pink-700 hover:bg-pink-800 text-white rounded-lg mb-4"
          >
            Go To Course
          </Link>
        </div>
      ))}
    </div>
  )
}
export default Courses
