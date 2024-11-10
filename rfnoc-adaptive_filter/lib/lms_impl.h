/* -*- c++ -*- */
/* 
 * Copyright 2024 <+YOU OR YOUR COMPANY+>.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#pragma once

#include <adaptive_filter/lms.h>
#include <adaptive_filter/lms_block_ctrl.hpp>

namespace gr {
  namespace adaptive_filter {

    class lms_impl : public lms
    {
     public:
      lms_impl(::uhd::rfnoc::noc_block_base::sptr block_ref);
      ~lms_impl();

      // Where all the action really happens

     private:
      ::uhd::rfnoc::lms_block_ctrl::sptr d_lms_ref;
    };

  } // namespace adaptive_filter
} // namespace gr

